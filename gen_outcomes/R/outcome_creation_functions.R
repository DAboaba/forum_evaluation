# Load necessary general functions ----
source(file.path("..", "R", "general_functions.R"))

# Load necessary packages for this script ----
pacman::p_load(magrittr)

create_outcomes <- function(universe_table,
                            incidents_table,
                            incident_date_var,
                            config_of_counts_and_timespans) {
    universe_table %>%
        create_diff_count_indicators(
            incidents_table = incidents_table,
            incident_date_var = {{ incident_date_var }},
            time = "future",
            config_of_counts_and_timespans = config_of_counts_and_timespans
        )
}
