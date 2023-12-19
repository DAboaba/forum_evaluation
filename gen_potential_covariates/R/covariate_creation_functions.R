# Ensure pacman is installed before attempting to use it ----
if (!require("pacman")) install.packages("pacman"); library(pacman)

# Load necessary packages for this script ----
pacman::p_load(magrittr, dplyr, lubridate)

# Load necessary general functions ----
source(file.path("..", "R", "general_functions.R"))


create_potential_covariates <- function(universe_table,
                                        incidents_table,
                                        incident_date_var,
                                        config_with_decisions) {
    regular_covariates <- universe_table %>%
        create_regular_covariates(config = config_with_decisions)

    backward_looking_covariates <- universe_table %>%
        create_bckwrd_looking_covs(
            incidents_table = incidents_table,
            incident_date_var = {{ incident_date_var }},
            config_of_counts_and_timespans = config_with_decisions
        )

    all_potential_covariates <- left_join(
        regular_covariates,
        backward_looking_covariates,
        by = "new.nysid"
    ) %>%
        # to deal with cases where there are no prior arrests
        mutate(across(
            c(min.two.wea.chrgs, starts_with("prior")),
            ~ ifelse(is.na(.x), 0, .x)
        ))
}

create_regular_covariates <- function(df, config) {
    num_days_in_month <- config[["num_days_in_month"]]

    df %>%
        mutate(
            modal.age = as.numeric(
                (dateinvite - modal.birth.date) / (num_days_in_month * 12)
            ),
            modal.age.sq = modal.age^2,
            under.age.30 = if_else(modal.age < 30, 1, 0),
            sample.entr.mo = as.character(lubridate::month(dateinvite))
        ) %>%
        group_by(ct) %>%
        mutate(
            num.eligible.indivs.ct = sum(
                (treatment_group %in% 1:2 & invited.between.cycles == TRUE) |
                    (treatment_group %in% 1:2 & is.na(invited.between.cycles))
            )
        ) %>%
        ungroup()
}

create_bckwrd_looking_covs <- function(universe_table,
                                       incidents_table,
                                       incident_date_var,
                                       config_of_counts_and_timespans) {
    universe_table %>%
        create_diff_count_indicators(
            incidents_table = incidents_table,
            incident_date_var = {{ incident_date_var }},
            time = "past",
            config_of_counts_and_timespans = config_of_counts_and_timespans
        ) %>%
        mutate(
            prior.arr.sq = prior.arr.count^2,
            min.two.wea.chrgs = if_else(prior.wea.arr.count >= 2, 1, 0)
        )
}

