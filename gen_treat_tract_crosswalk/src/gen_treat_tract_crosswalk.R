# Ensure pacman is installed before attempting to use it ----
if (!require("pacman")) install.packages("pacman"); library(pacman)

# Load necessary packages for task ----
pacman::p_load(here, magrittr, feather)

# Load general and/or task specifc functions ----
source(file.path("..", "R", "general_functions.R"))

# Check for existence of and/or create task output directory ----
task_output_dir <- file.path("output")
check_create_dir(task_output_dir)

# Read in config file specifying unique decisions made for this task ----
task_config <- yaml::read_yaml(file.path("hand", "config.yaml"))

# Specify previous task directories ----
previous_task_dir <- here(task_config$previous_task_name)
task_input_dir <- file.path(previous_task_dir, "output")

# Read in universe table from previous task ----
df_universe_table <- feather::read_feather(
    file.path(task_input_dir, "universe_table.feather"))

# create treatment_tract_crosswalk ----
df_treat_tract_xwlk_tract_lvl <- df_universe_table %>%
    select(ct, block, treatment_group) %>%
    arrange(ct) %>%
    distinct()

df_treat_tract_xwlk_arr_lvl <- df_universe_table %>%
    select(new.id, ct, block, treatment_group, mearstat, prog_att, alt_att_flag) %>%
    arrange(new.id, ct)

# Write out treatment_tract_crosswalk ----
feather::write_feather(
    df_treat_tract_xwlk_tract_lvl,
    file.path(task_output_dir, "treatment_tract_crosswalk_tract_lvl.feather")
)

feather::write_feather(
    df_treat_tract_xwlk_arr_lvl,
    file.path(task_output_dir, "treatment_tract_crosswalk_arrest_lvl.feather")
)
