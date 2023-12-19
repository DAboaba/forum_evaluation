# Ensure pacman is installed before attempting to use it ----
if (!require("pacman")) install.packages("pacman"); library(pacman)

# Load necessary packages for task ----
pacman::p_load(purrr, yaml, here, feather, dplyr, magrittr)

# Load general and/or task specifc functions ----
source(file.path("..", "R", "general_functions.R"))
source(file.path("R", "outcome_creation_functions.R"))

# Check for existence of and/or create task output directory ----
task_output_dir <- file.path("output")
check_create_dir(task_output_dir)

# Read in config file specifying unique decisions made for this task ----
config_names <- c("primary", "pvio_outcomes", "arr_outcomes")
config_paths <- file.path("hand", paste0(config_names, "_config.yml"))
list_task_configs <- map(config_paths, read_yaml)
names(list_task_configs) <- config_names

# Specify previous task directories ----
previous_task_dir <- here(list_task_configs$primary$previous_task_name)
task_input_dir <- file.path(previous_task_dir, "output")

# Specify name of input files ----
task_input_files <- c(
    "violation_incidents",
    "arrest_incidents",
    "universe_table"
)

# Specify path of input files ----
task_input_files_path <- file.path(
    task_input_dir,
    paste0(task_input_files, ".feather")
)

# Read in cleaned incidents and universe tables from previous task ----
list_input_files_df <- map(task_input_files_path, read_feather)
names(list_input_files_df) <- task_input_files

# Create outcomes ----
# Create parole violation outcomes ----
df_univ_table_pvio_outcomes <- create_outcomes(
    universe_table = list_input_files_df$universe_table,
    incidents_table = list_input_files_df$violation_incidents %>%
        rename(new.id = new_id),
    incident_date_var = ISSDT,
    config_of_counts_and_timespans = list_task_configs$pvio_outcomes
)

# Create arrest outcomes ----
df_univ_table_arr_outcomes <- create_outcomes(
    universe_table = list_input_files_df$universe_table,
    incidents_table = list_input_files_df$arrest_incidents,
    incident_date_var = arr.incident.date,
    config_of_counts_and_timespans = list_task_configs$arr_outcomes
)

# Combine both sets of outcomes in one df ----
df_universe_table_outcomes <- full_join(
    df_univ_table_pvio_outcomes,
    df_univ_table_arr_outcomes,
    "new.nysid"
) %>%

    # to deal with cases where there are no future arrests
    mutate(across(
        starts_with(c(
            "ftr.arr",
            "ftr.vfo.arr",
            "ftr.wea.arr",
            "ftr.pvio."
        )),
        ~ ifelse(is.na(.x), 0, .x)
    ))

# Write out universe_table_outcomes----
feather::write_feather(
    df_universe_table_outcomes,
    file.path(task_output_dir, "universe_table_outcomes.feather")
)
