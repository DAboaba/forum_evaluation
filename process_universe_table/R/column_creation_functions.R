# Ensure pacman is installed before attempting to use it ----
if (!require("pacman")) install.packages("pacman"); library(pacman)

# Load necessary packages for script ----
pacman::p_load(dplyr, magrittr, purrr)

create_fup_fts_mlti_ref_date <- function(df, config) {
    num_days_in_month <- config[["num_days_in_month"]]
    followup_ref_date <- config[["followup_ref_date"]]

    followup_features <- purrr::map_dfc(
        .x = followup_ref_date,
        .f = create_fup_fts_from_ref_date,
        df = df,
        num_days_in_month = num_days_in_month
    )

    bind_cols(df, followup_features)
}


create_fup_fts_from_ref_date <- function(df,
                                         num_days_in_month,
                                         followup_ref_date) {
    num_days_in_month <- as.double(num_days_in_month)

    followup_duration_name <- glue::glue("followup.dur.{followup_ref_date}")
    followup_avail_3mos_name <- glue::glue("followup.avail.3mos.{followup_ref_date}")
    followup_avail_6mos_name <- glue::glue("followup.avail.6mos.{followup_ref_date}")
    followup_avail_12mos_name <- glue::glue("followup.avail.12mos.{followup_ref_date}")
    followup_avail_24mos_name <- glue::glue("followup.avail.24mos.{followup_ref_date}")

    # rudimentary check to make sure followup_ref_date is at least numeric
    if (grepl("[0-9]", followup_ref_date)) {
        df %<>%
            mutate({{ followup_duration_name }} :=
                       difftime(followup_ref_date, dateinvite, units = "days"))
    } else {
        df %<>%
            mutate({{ followup_duration_name }} :=
                       difftime(.data[[followup_ref_date]], dateinvite, units = "days"))
    }

    df %>%
        transmute(
            {{ followup_duration_name }} := .data[[{{ followup_duration_name }}]],
            {{ followup_avail_3mos_name }} := .data[[{{ followup_duration_name }}]] >= num_days_in_month * 3,
            {{ followup_avail_6mos_name }} := .data[[{{ followup_duration_name }}]] >= num_days_in_month * 6,
            {{ followup_avail_12mos_name }} := .data[[{{ followup_duration_name }}]] >= num_days_in_month * 12,
            {{ followup_avail_24mos_name }} := .data[[{{ followup_duration_name }}]] >= num_days_in_month * 24
        )
}
