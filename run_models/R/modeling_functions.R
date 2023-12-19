# Ensure pacman is installed before attempting to use it ----
if (!require("pacman")) install.packages("pacman"); library(pacman)

# Load necessary packages for this script ----
pacman::p_load(dplyr, magrittr, tidyr, stringr, purrr, broom, AER, estimatr)

evaluate_multiple_model_grids <- function(path_to_model_configs) {
    model_config_paths <- list.files(
        path = path_to_model_configs, pattern = "^(model)*[1-9]_config.yaml"
    )

    model_config_paths <- file.path(path_to_model_configs, model_config_paths)

    multiple_model_grid <- purrr::pmap_dfr(
        list(model_config_paths),
        expand_and_prune_model_grid
    )
}


add_regression_models_to_grid <- function(df,
                                          model_grid) {
    model_grid %>%
        dplyr::rowwise() %>%
        mutate(
            data_for_reg = list(
                filter_data_for_reg(
                    df,
                    chosen_treatment_groups = selected_treatment_groups,
                    chosen_age_restriction = age_restriction,
                    chosen_min_wea_chrge_restriction =  min_wea_chrge_restriction,
                    model_label = model_label
                )
            ),
            reg_mod = list(
                match.fun(model_fn)(formula = as.formula(regression_formula),
                                    data = data_for_reg,
                                    # robust clustered standard error implementation
                                    clusters = ct,
                                    se_type = "stata"
                )
            )
        ) %>%
        ungroup()
}


tidy_models_from_grid <- function(model_grid, model_types) {
    model_grid <- dplyr::rowwise(model_grid)

    per_model_overall_results <- dplyr::summarise(
        model_grid,
        broom::glance(reg_mod)
    )

    per_model_treatment_results <- model_grid %>%
        summarise(broom::tidy(reg_mod,
                              conf.int = TRUE,
                              conf.level = 0.95
        ))

    colnames(per_model_overall_results) <- paste0(
        "overall_",
        colnames(per_model_overall_results)
    )


    if (model_types == "OLS") {
        per_model_treatment_results %<>%
            filter(term %in% paste0("treatment", "_", "group", "_", 1:3))
    } else if (model_types == "2SLS") {
        per_model_treatment_results %<>%
            filter(term == "prog_att")
    }


    model_grid <- bind_cols(
        model_grid,
        per_model_treatment_results,
        per_model_overall_results
    )

    model_grid %>%
        rowwise() %>%
        mutate(
            control_mean = list(data_for_reg %>%
                                    filter(get(treatment_indicator) == 0) %$%
                                    mean(get(outcomes)))
        ) %>%
        ungroup()
}


expand_and_prune_model_grid <- function(model_config_path) {
    model_grid <- model_config_path %>%
        expand_model_grid() %>%
        prune_model_grid()
}


expand_model_grid <- function(model_config_path) {
    model_config <- yaml::read_yaml(model_config_path)
    full_model_grid <- tidyr::expand_grid(
        model = stringr::str_extract(model_config$model, "[0-9]"),
        model_types = model_config$model_types,
        outcomes = model_config$outcomes,
        selected_treatment_groups = list(model_config$treatment_groups),
        treatment_indicator = model_config$treatment_indicator,
        age_restriction = model_config$age_restrictions,
        min_wea_chrge_restriction = model_config$min_wea_chrge_restrictions,
        controls = paste0(model_config$controls, collapse = " + "),
        fixed_effects = paste0(
            "factor(", model_config$fixed_effects, ")",
            collapse = " + "
        )
    ) %>%
        mutate(
            model_fn = if_else(model_types == "2SLS", "iv_robust", "lm_robust"),
            regression_formula = if_else(model_types == "2SLS",
                                         # if a 2SLS model use this formula
                                         paste0(
                                             outcomes,
                                             " ~ ",
                                             paste0(model_config$iv_treat_indicator,
                                                    collapse = " + "
                                             ),
                                             " + ",
                                             controls,
                                             " + ",
                                             fixed_effects,
                                             " | ",
                                             treatment_indicator,
                                             " + ",
                                             controls,
                                             " + ",
                                             fixed_effects
                                         ),
                                         # otherwise use this
                                         paste0(
                                             outcomes,
                                             " ~ ",
                                             treatment_indicator,
                                             " + ",
                                             controls,
                                             " + ",
                                             fixed_effects
                                         )
            )
        ) %>%
        mutate(across(everything(), ~ na_if(.x, "NA"))) %>%
        mutate(across(
            c(model, age_restriction, min_wea_chrge_restriction),
            as.numeric
        ))
}


prune_model_grid <- function(full_model_grid) {
    pruned_model_grid <- full_model_grid

    model <- dplyr::slice(pruned_model_grid, 1)
    model <- model[["model"]]

    if (str_detect(model, "1") == TRUE) {
        # certain potential variants of model 1 that we don't need are created by
        #  expand_model_grid so we filter those out
        pruned_model_grid %<>%
            filter(!(model_types %in% c("2SLS", "Hazard ratio"),
                     !(model_types %in% c("2SLS", "Hazard ratio") & !is.na(age_restriction)),
                     !(model_types %in% c("2SLS", "Hazard ratio") &
                           !is.na(min_wea_chrge_restriction)),
                     !(!is.na(age_restriction)),
                     !(!is.na(min_wea_chrge_restriction)),
                     !(!is.na(age_restriction) & !is.na(min_wea_chrge_restriction)))
                   } else {
                       pruned_model_grid
                   }


    # create a model label that describes all the relevant model details
    pruned_model_grid %<>%
        mutate(
            model_label = paste0(
                "Impact Estimate ", model, ": ", model_types, " of ",
                outcomes
            ),
            model_label = str_remove(model_label, ".trunc"),
            model_label = if_else(!is.na(age_restriction),
                                  paste0(model_label, " - ", "under 30"),
                                  model_label
            ),
            model_label = if_else(!is.na(min_wea_chrge_restriction),
                                  paste0(model_label, " - ", "min 2 weapons charges"),
                                  model_label
            ),
            model_label = if_else(grepl(".trunc.", outcomes),
                                  paste0(model_label, " - ", "limited"),
                                  model_label
            )
        ) %>%
        select(starts_with("model"), everything())
    }


filter_data_for_reg <- function(df,
                                chosen_treatment_groups,
                                chosen_age_restriction,
                                chosen_min_wea_chrge_restriction,
                                model_label) {
    df_for_reg <- filter(df,
                         treatment_group %in% unlist(chosen_treatment_groups))

    if (!is.na(chosen_age_restriction)) {
        df_for_reg %<>% filter(modal.age < chosen_age_restriction)
    }

    if (!is.na(chosen_min_wea_chrge_restriction) &
        chosen_min_wea_chrge_restriction == TRUE) {
        df_for_reg %<>% filter(min.two.wea.chrgs == 1)
    }

    if (grepl("limited", model_label)) {
        if (str_detect(model_label, "3.mos")) {
            df_for_reg %<>%
                filter(`followup.avail.3mos.2014-08-01` == TRUE)
        } else if (str_detect(model_label, "6.mos")) {
            df_for_reg %<>%
                filter(`followup.avail.6mos.2014-08-01` == TRUE)
        } else if (str_detect(model_label, "1.yr")) {
            df_for_reg %<>%
                filter(`followup.avail.12mos.2014-08-01` == TRUE)
        } else {
            df_for_reg <- df_for_reg
        }
    }

    df_for_reg
}
