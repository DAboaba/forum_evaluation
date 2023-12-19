# Ensure pacman is installed before attempting to use it ----
if (!require("pacman")) install.packages("pacman"); library(pacman)

# Load necessary packages for script ----
pacman::p_load(purrr, dplyr, magrittr)

# Load necessary general functions ----
source(file.path("..", "..", "R", "general_functions.R"))

recreate_multi_table <- function(df_with_models,
                                 table_names,
                                 config_with_models_for_table) {
    tables <- map(.x = table_names,
                  .f = recreate_table,
                  df_with_models = df_with_models,
                  config_with_models_for_table = config_with_models_for_table)

    names(tables) <- table_names

    tables
}

recreate_table <- function(df_with_models,
                           table_name,
                           config_with_models_for_table) {
    table <- df_with_models %>%
        filter(Model %in% config_with_models_for_table[[table_name]][[1]]) %>%
        # outcome grouping for later sections
        mutate(outcome_group = case_when(
            # subgroups
            grepl("1.*ftr.pvio.*(under 30|min 2 weapons)", Model) ~ "Violations",
            grepl("1.*(arr|vfo.arr).*(under 30|min 2 weapons)", Model) ~ "Arrests",
            grepl("(1|2|3).*ftr.arr", Model) ~ "All Arrests",
            grepl("(1|2|3).*ftr.vfo.arr", Model) ~ "Violent Felony Arrests",
            grepl("(1|2|3).*ftr.pvio.new.arr", Model) ~ "New Arrest Violations",
            grepl("(1|2|3).*ftr.pvio.abs", Model) ~ "Absconding Violations",
            grepl("(1|2|3).*ftr.pvio.tech", Model) ~ "Technical Violations",
            grepl("(1|2|3).*ftr.pvio.", Model) ~ "All Violations",
            grepl("complaints_total", Model) ~ "All Complaints",
            grepl("complaints_weapon", Model) ~ "Weapon-Related Complaints",
            grepl("arrests_total", Model) ~ "All Arrests",
            grepl("arrests_weapon", Model) ~ "Weapon-Related Arrests",
            grepl("shootings_total", Model) ~ "All Shootings"
        )) %>%

        # ensure proper ordering of outcome_groups
        mutate(outcome_group = factor(
            outcome_group,
            levels = c(
                "All Arrests", "Violent Felony Arrests",
                c(paste(
                    c("All", "New Arrest", "Absconding", "Technical"),
                    "Violations"
                )),
                "Arrests", "Violations",
                "Weapon-Related Arrests",
                "All Complaints", "Weapon-Related Complaints",
                "All Shootings"
            )
        )) %>%
        arrange(outcome_group) %>%

        # outcome relabelling
        mutate(Outcome = case_when(
            # site specific
            grepl("1.*.(1.yr|6.mos).*specific", Model) ~
                str_remove(str_remove(Model, " specific"), "Impact Estimate 1.*- "),

            # subgroup specific
            grepl("1.*ftr.vfo.arr.(1.yr|6.mos).*(under 30|min 2)", Model) ~ "Violent Felony",
            grepl("1.*ftr.pvio.new.arr.(1.yr|6.mos).*(under 30|min 2)", Model) ~ "Arrest",
            grepl("1.*ftr.pvio.abs.(1.yr|6.mos).*(under 30|min 2)", Model) ~ "Absconding",
            grepl("1.*ftr.pvio.tech.(1.yr|6.mos).*(under 30|min 2)", Model) ~ "Technical",
            grepl("1.*ftr.(arr|pvio).(1.yr|6.mos).*(under 30|min 2)", Model) ~ "All",

            # everything else
            grepl("(1|2|3).*ftr.*ever", Model) ~ "Any",
            grepl("(1|2|3).*ftr.*3.mos", Model) ~ "Within 3 months",
            grepl("(1|2|3).*ftr.*6.mos", Model) ~ "Within 6 months",
            grepl("((1|2|3).*ftr.*1.yr|12)", Model) ~ "Within 1 year",
            grepl("((1|2|3).*ftr.*2.yr|24)", Model) ~ "Within 2 years")) %>%
        # ensure proper ordering of outcomes within groups
        group_by(outcome_group) %>%
        mutate(within_group_order = case_when(
            grepl("ever", Model) ~ -Inf,
            grepl("3.mos", Model) ~ 3,
            grepl("6.mos", Model) ~ 6,
            grepl("(1.yr|12)", Model) ~ 12,
            grepl("(2.yr|24)", Model) ~ 24)) %>%
        ungroup(outcome_group) %>%
        arrange(outcome_group, within_group_order)

    # including rough significance
    table %<>%
        mutate(`Treatment Effect` = case_when(
            `p-value` < 0.01 ~ paste0(round(`Treatment Effect`, 3), "***"),
            `p-value` < 0.05 ~ paste0(round(`Treatment Effect`, 3), "**"),
            `p-value` < 0.1 ~ paste0(round(`Treatment Effect`, 3), "*"),
            `p-value` > 0.1 ~ paste0(round(`Treatment Effect`, 3))))

    if (!is.null(config_with_models_for_table[[table_name]][["desired_cols"]])) {
        table %<>%
            select(
                config_with_models_for_table[[table_name]][["desired_cols"]],
                outcome_group, Model, within_group_order
            )
    } else {
        table
    }

    table %>%
        mutate(across(where(is.numeric), ~ round(.x, 3))) %>%
        sample_size_to_row()
}


sample_size_to_row <- function(df) {
    samp_size_values <- as.double(unique(df[["Sample Size"]]))
    if (length(samp_size_values) == 1) {
        colnames_to_use <- colnames(df %>% select(-c("Sample Size")))
        samp_size_row <- c(
            "Sample Size",
            samp_size_values,
            rep("", length(colnames_to_use) - 2)
        )
        names(samp_size_row) <- colnames_to_use
        df %<>%
            mutate(across(everything(), ~ as.character(.x)),
                   `Sample Size` = NULL)
        bind_rows(df, samp_size_row)
    } else {
        df
    }
}
