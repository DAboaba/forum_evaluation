# Ensure pacman is installed before attempting to use it ----
if (!require("pacman")) install.packages("pacman"); library(pacman)

# Load necessary packages for task ----
pacman::p_load(yaml, here, purrr, feather, magrittr)

# Load general and/or task specifc functions ----
source(file.path("..", "R", "general_functions.R"))
source(file.path("R", "covariate_creation_functions.R"))

# Check for existence of and/or create task output directory ----
task_output_dir <- file.path("output")
check_create_dir(task_output_dir)

# Read in config file specifying unique decisions made for this task ----
task_config <- yaml::read_yaml(file.path("hand", "config.yml"))

# Specify previous task directories ----
previous_task_dir <- here(task_config$previous_task_name)
task_input_dir <- file.path(previous_task_dir, "output")

# Specify name of input files ----
task_input_files <- c("arrest_incidents", "universe_table")

# Specify path of input files ----
task_input_files_path <- file.path(
    task_input_dir,
    paste0(task_input_files, ".feather")
)

# Read in cleaned arrest incidents, and universe tables from previous task ----
list_input_files_df <- map(task_input_files_path, read_feather)
names(list_input_files_df) <- task_input_files

# Create potential covariates and Dummy specified covariates ----
df_universe_table_covariates <- create_potential_covariates(
    universe_table = list_input_files_df$universe_table,
    incidents_table = list_input_files_df$arrest_incidents,
    incident_date_var = arr.incident.date,
    config_with_decisions = task_config
) %>%
    dummy_features(specified_features = task_config$covariates_to_dummy)

# Write out df_select_arrests_covariates ----
feather::write_feather(
    df_universe_table_covariates,
    file.path(task_output_dir, "universe_table_covariates.feather")
)
