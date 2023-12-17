# Ensure pacman is installed before attempting to use it ----
if (!require("pacman")) install.packages("pacman"); library(pacman)

# Load necessary packages for task ----
pacman::p_load(yaml, Hmisc, magrittr, dplyr, feather)

# Load general and/or task specifc functions ----
source(file.path("..", "R", "general_functions.R"))
source(file.path("R", "column_creation_functions.R"))

# Check for existence of and/or create task output directory ----
task_output_dir <- file.path("output")
check_create_dir(task_output_dir)

# Read in config file specifying unique decisions made for this task ----
task_config <- yaml::read_yaml(file.path("hand", "config.yaml"))

# Read in raw data files and convert each to tibble format ----
data <- Hmisc::spss.get(task_config$raw_data_path) %>%
    as_tibble() %>%
    recode_yr_vars() %>%
    create_date_feature("arr.date")

# create arrest incidents table from deduplicated cch data  ----
data_dedup <- deduplicate_arrest_cases(data)

# capture unique arrest indicator info spread across duplicated cases
data_arr_indicators <- data %>%
    create_arr_indicator_features(config = task_config) %>%
    group_by(new.id, arr.date, arr.ori, arr.nycpd.nysp) %>%
    summarise(across(ends_with(".indicator"), max)) %>%
    ungroup()

# full_join deduplicated cch data with cch arr indicators
df_arrest_incidents_table <- data_dedup %>%
    full_join(data_arr_indicators,
              by = c("new.id", "arr.date", "arr.ori", "arr.nycpd.nysp")) %>%
    select(new.id, stint.id, arr.date, ends_with(".indicator")) %>%
    rename(arr.incident.date = arr.date)

# Write our incidents_table ----
feather::write_feather(
    df_arrest_incidents_table,
    file.path(task_output_dir, "arrest_incidents.feather")
)
