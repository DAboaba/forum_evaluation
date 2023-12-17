# Ensure pacman is installed before attempting to use it ----
if (!require("pacman")) install.packages("pacman"); library(pacman)

# Load necessary packages for task ----
pacman::p_load(yaml, Hmisc, magrittr, haven, dplyr, feather)

# Load general and/or task specifc functions ----
source(file.path("..", "R", "general_functions.R"))

# Check for existence of and/or create task output directory ----
task_output_dir <- file.path("output")
check_create_dir(task_output_dir)

# Read in config file specifying unique decisions made for this task ----
task_config <- yaml::read_yaml(file.path("hand", "config.yaml"))

# Read in raw data files and convert each to tibble format ----
a_data <- Hmisc::spss.get(task_config$a_data_path) %>%
    as_tibble() %>%
    # remove columns reserved for arrest incidents table
    select(-c(arr.firearm, arr.charge, arr.vfo))

d_data <- haven::read_sav(task_config$d_data_path)

b_data <- haven::read_sav(task_config$b_data_path) %>%
    # remove columns reserved for violation incidents table
    select(-c(starts_with(c("WTYP.", "ISSDT."))))

c_data <- haven::read_dta(task_config$c_data_path)

# Combine raw datasets ----
df_all_cases <- a_data %>%
    mutate(new.id = as.double(new.id)) %>%
    left_join(d_data,
              by = c("new.id" = "new_id", "stint.id" = "new_stint_id")) %>%
    full_join(b_data, by = c("new.id" = "new_id", "new_in_house_id")) %>%
    left_join(c_data, by = "pseudo_treat")

# Filter cases into a universe table ----
df_universe_table <- df_all_cases %>%
    # line 47 always results in a warning - "warning message: 6 failed to parse"
    # - as there are 6 cases where all info on arr.date (day, month, and year)
    # is missing
    suppressWarnings(recode_yr_vars()) %>%
    create_date_feature("arr.date") %>%
    deduplicate_arrest_cases() %>%
    arrange(new.id, arr.date) %>%
    mutate(max.data.arr.date = max(arr.date)) %>%
    group_by(new.id) %>%
    mutate(next.arr.date = lead(arr.date, n = 1L),
           max.arr.date = max(arr.date),
           invited.between.cycles = dateinvite > arr.date &
               dateinvite <= next.arr.date) %>%
    ungroup() %>%
    filter(invited.between.stints == TRUE | is.na(invited.between.stints))

# Write our incidents_table ----
feather::write_feather(
    df_universe_table,
    file.path(task_output_dir, "universe_table.feather")
)
