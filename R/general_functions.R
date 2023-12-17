# Ensure pacman is installed before attempting to use it ----
if (!require("pacman")) install.packages("pacman"); library(pacman)

# Load necessary packages for this script ----
pacman::p_load(yaml, magrittr, dplyr, purrr, glue, stringr, tidyr, lubridate)

check_create_dir <- function(dir_path) {
    if (!dir.exists(dir_path)) dir.create(dir_path)
}

# Recode a column with a corresponding yaml codebook file
recode_column_with_codebook <- function(df, var_name) {

    # Begin to build path for correct yaml file by using supplied data source
    path <- file.path("hand", "codebooks")

    # Complete path to correct yaml file by appending variable name and .yaml
    path <- paste0(path, "/", var_name, ".yaml")

    # Read yaml data stored at generated path into temp_codebook
    temp_codebook <- yaml::read_yaml(path)

    # Convert temp_codebook from list into a named vector
    level_values <- unlist(temp_codebook)

    # Store level names in level_names object
    level_names <- names(level_values)

    # Strip names from original named vector that temp_codebook was converted to
    names(level_values) <- NULL

    # Convert variable to a factor and supply the correct levels and lables
    df %>%
        mutate(
            {{ var_name }} :=
                factor(
                    .data[[var_name]],
                    levels = level_names,
                    labels = level_values
                )
        )
}


create_diff_count_indicators <- function(universe_table,
                                         incidents_table,
                                         incident_date_var,
                                         time,
                                         config_of_counts_and_timespans,
                                         truncation_cutoff) {
    full_ids_tbl <- tibble(new.id = universe_table %>%
                               group_by(new.id) %>%
                               summarise(n()) %$%
                               new.id)

    data <- prepare_to_calc_time_agg_feat(
        universe_table = universe_table,
        incidents_table = incidents_table,
        incident_date_var = {{ incident_date_var }},
        time = time,
        truncation_cutoff = truncation_cutoff
    )

    lim_ids_time_agg <- data %>%
        group_by(new.id) %>%
        summarise(n()) %$%
        new.id

    count_types <- config_of_counts_and_timespans[["count_types"]]
    truncated_count_types <- count_types[grepl(".trunc", count_types)]
    regular_count_types <- count_types[!grepl(".trunc", count_types)]

    timespans <- config_of_counts_and_timespans[["timespans_in_months"]]

    data_with_regular_outcomes <- purrr::map_dfc(
        .x = regular_count_types,
        .f = calc_multi_count_indicators,
        df = data,
        timespans_in_months = timespans,
        config_with_month_to_day_conv = config_of_counts_and_timespans
    )

    data_with_outcomes <- bind_cols(
        # reattach ids because they are removed in the
        # calc_multi_count_indicators function
        tibble(new.id = lim_ids_time_agg),
        data_with_regular_outcomes
    )

    # if there are truncated count_types (e.g. if the count_types and regular
    # count_types vectors aren't identical) run the below chunk
    # this needs to be done separately because more filtering is needed for the
    # truncated outcomes, hence the number of ids returned are different
    if (!identical(count_types, regular_count_types)) {
        lim_ids_truncated <- data %>%
            filter({{ incident_date_var }} <= truncated_cutoff) %>%
            group_by(new.id) %>%
            summarise(n()) %$%
            new.id

        data_with_truncated_outcomes <- purrr::map_dfc(
            .x = truncated_count_types,
            .f = calc_multi_count_indicators,
            df = data,
            timespans_in_months = timespans,
            config_with_month_to_day_conv = config_of_counts_and_timespans,
            truncation_cutoff = truncation_cutoff,
            # only needed for final filtering for truncated outcome measures
            incident_date_var = {{ incident_date_var }}
        )

        data_with_truncated_outcomes <- bind_cols(
            # reattach ids similar to above
            tibble(new.id = lim_ids_truncated),
            data_with_truncated_outcomes
        )

        # since ids in data_with_truncated_outcomes are a subset of ids in
        # data_with_outcomes a full_join should be equivalent to a left_join. I use
        # a full_join to be safe
        data_with_outcomes <- full_join(
            data_with_outcomes,
            data_with_truncated_outcomes,
            by = "new.id"
        )
    }


    # binding the data back to the full set of ids to avoid artificially or
    # accidentally truncating cases
    data_with_outcomes <- left_join(
        full_ids_tbl,
        data_with_outcomes,
        by = "new.id"
    )

    data_with_outcomes
}


prepare_to_calc_time_agg_feat <- function(universe_table,
                                          incidents_table,
                                          incident_date_var,
                                          time = "past",
                                          truncation_cutoff,
                                          comp_date_var) {
    data <- left_join(
        universe_table,
        incidents_table,
        by = "new.id") %>%
        # not sure this filter actually does anything
        filter(!is.na({{ incident_date_var }}))

    if (time == "past") {
        data <- data %>% filter({{ incident_date_var }} < {{ comp_date_var }})
    } else if (time == "future") {
        data <- data %>% filter({{ incident_date_var }} > {{ comp_date_var }})
    }

    data <- data %>%
        mutate(
            time_window = difftime({{ incident_date_var }},
                                   {{ comp_date_var }},
                                   units = "days"),
            time_window_trunc = difftime({{ incident_date_var }},
                                         truncation_cutoff,
                                         units = "days")
        ) %>%
        group_by(new.id)

    # remove incidents just before incident leading to forum
    if (time == "past") {
        data <- data %>%
            mutate(inc_number = cumsum(inc.indicator)) %>%
            filter(inc_number != max(inc_number))
    }

    data
}


calc_multi_count_indicators <- function(df,
                                        timespans_in_months,
                                        count_type,
                                        config_with_month_to_day_conv,
                                        truncation_cutoff,
                                        incident_date_var = NULL) {
    if ("any" %in% timespans_in_months) {
        timespans_in_months[timespans_in_months == "any"] <- Inf
    }

    timespans_in_months <- as.numeric(timespans_in_months)

    purrr::map_dfc(
        .x = timespans_in_months,
        .f = create_count_indicator,
        df = df,
        count_type = count_type,
        config_with_month_to_day_conv = config_with_month_to_day_conv,
        truncation_cutoff = truncation_cutoff,
        incident_date_var = {{ incident_date_var }}
    )
}


create_count_indicator <- function(df,
                                   count_type,
                                   config_with_month_to_day_conv,
                                   truncation_cutoff,
                                   timespan_in_months = Inf,
                                   incident_date_var = NULL) {
    unit <- "mos"
    timespan_col_label <- timespan_in_months
    chosen_time_window <- "time_window"

    # changes to do truncation
    if (grepl("trunc", count_type)) {
        df <- df %>% filter({{ incident_date_var }} <= truncation_cutoff)
    }


    if (timespan_in_months >= 12) {
        timespan_col_label <- timespan_col_label / 12
        unit <- "yr"
    }

    count_var_name <- glue::glue("{count_type}.count.{timespan_col_label}.{unit}")
    count_var_indicator <- glue::glue("{count_type}.{timespan_col_label}.{unit}")

    col_to_sum <- stringr::str_remove(count_type, "(prior.|ftr.)")
    col_to_sum <- stringr::str_remove(col_to_sum, ".trunc")
    col_to_sum <- paste0(col_to_sum, ".", "indicator")

    num_days_in_month <- as.double(
        config_with_month_to_day_conv[["num_days_in_month"]]
    )


    if (timespan_in_months == Inf) {
        count_var_name <- glue::glue("{count_type}.count")
        count_var_indicator <- glue::glue("{count_type}.ever")
    }


    df %<>%
        summarise({{ count_var_name }} :=
                      sum((abs(.data[[{{ chosen_time_window }}]]) <=
                               (unlist(timespan_in_months) * num_days_in_month)) &
                              .data[[{{ col_to_sum }}]] == TRUE))

    df %<>%
        mutate({{ count_var_indicator }} :=
                   if_else(.data[[{{ count_var_name }}]] > 0, 1, 0))

    df[["new.id"]] <- NULL

    df
}

create_date_feature <- function(df, date_feature_name) {
    date_prefix <- stringr::str_remove(date_feature_name, ".date")
    day_bit <- paste0(date_prefix, ".day")
    month_bit <- paste0(date_prefix, ".mo")
    year_bit <- paste0(date_prefix, ".yr")

    df %>%
        unite(
            col = {{ date_feature_name }},
            {{ year_bit }},
            {{ month_bit }},
            {{ day_bit }},
            sep = "-",
            remove = FALSE
        ) %>%
        mutate({{ date_feature_name }} := ymd(.data[[date_feature_name]]))
}


dummy_features <- function(df, specified_features) {
    df %>%
        fastDummies::dummy_cols(
            select_columns = specified_features,
            remove_first_dummy = FALSE,
            remove_selected_columns = FALSE
        )
}


deduplicate_cases <- function(df) {
    df %>%
        group_by(new.id, arr.date, arr.ori, arr.nysp) %>%
        mutate(max.stint.id = max(stint.id)) %>%
        ungroup() %>%
        mutate(max.stint.id.ind = if_else(max.stint.id == stint.id, 1, 0)) %>%
        group_by(new.id, arr.date, arr.ori, arr.nysp) %>%
        arrange(desc(max.stint.id.ind)) %>%
        filter(max.stint.id.ind == 1) %>%
        ungroup()
}

recode_yr_vars <- function(df) {
    df %>%
        # dates are stored in CYY (Century Year Year) format
        # where C = 0 for 1900 & C = 1 for 2000
        mutate(across(ends_with(".yr"), ~ (as.numeric(.x) + 1900)))
}

