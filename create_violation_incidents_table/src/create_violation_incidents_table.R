# Ensure pacman is installed before attempting to use it ----
if (!require("pacman")) install.packages("pacman"); library(pacman)

# Load necessary packages for task ----
pacman::p_load(yaml, haven, magrittr, tidyr, feather)

# Load general and/or task specifc functions ----
source(file.path("..", "R", "general_functions.R"))
source(file.path("R", "column_creation_functions.R"))
source(file.path("R", "column_recode_functions.R"))

# Check for existence of and/or create task output directory ----
task_output_dir <- file.path("output")
check_create_dir(task_output_dir)

# Read in raw data files and convert each to tibble format ----
data <- haven::read_sav(data_path)

# create violation incidents table from doccs data ----
df_violation_incidents_table <- data %>%
    select(new_id, starts_with(c("WTYP.", "ISSDT."))) %>%
    mutate(across(starts_with(c("WTYP.", "ISSDT.")), as.character)) %>%
    gather("key", "value", -new_id) %>%
    separate(key, c("key", "violation_num"), sep = "\\.") %>%
    spread(key, value) %>%
    select(everything()) %>%
    recode_wtyp_col() %>%
    mutate(ISSDT = ymd(ISSDT)) %>%
    create_pvio_indicator_features()

# Write our incidents_table ----
feather::write_feather(
    df_violation_incidents_table,
    file.path(task_output_dir, "violation_incidents.feather")
)
