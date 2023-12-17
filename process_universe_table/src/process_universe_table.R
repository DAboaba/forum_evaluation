# Ensure pacman is installed before attempting to use it ----
if (!require("pacman")) install.packages("pacman"); library(pacman)

# Load necessary packages for task ----
pacman::p_load(yaml, here, purrr, feather, magrittr, lubridate)

# Load general and/or task specifc functions ----
source(file.path("..", "R", "general_functions.R"))
source(file.path("R", "column_creation_functions.R"))
source(file.path("R", "column_recode_functions.R"))

# Check for existence of and/or create task output directory ----
task_output_dir <- file.path("output")
check_create_dir(task_output_dir)

# Read in config file specifying unique decisions made for this task ----
task_config <- yaml::read_yaml(file.path("hand", "config.yaml"))

# Specify previous task directories ----
previous_task_dir <- here(task_config$previous_task_name)
task_input_dir <- file.path(previous_task_dir, "output")

# Specify name of input files ----
task_input_files <- c("universe_table")

# Specify path of input files ----
task_input_files_path <- file.path(
    task_input_dir,
    paste0(task_input_files, ".feather")
)

# Read in incident and universe tables from previous task ----
list_input_files_df <- map(task_input_files_path, read_feather)
names(list_input_files_df) <- task_input_files

# create and/or recode necessary columns in incident and universe tables ----
list_input_files_df$universe_table %<>%
    recode_column_with_codebook(var_name = "modal.sex") %>%
    recode_column_with_codebook(var_name = "arr.re.combi") %>%
    recode_mearstat() %>%
    mutate(arr.age = as.numeric(arr.age),
           mearatdt = ymd(mearatdt),
           mearindt = ymd(mearindt)) %>%
    create_date_feature("modal.birth.date") %>%
    # a warning message is generated because there are 8 cases where all info on
    #  arr.birth (day, month, and year) is missing
    suppressWarnings(create_date_feature("arr.birth.date")) %>%
    mutate(prog_att = ifelse(mearstat == "attended", 1, 0),
           alt_att_flag = ifelse(treatment_group == 1 &
                                             inhouse_idFlg %% 2 == 1, 1, 0)) %>%
    create_fup_fts_mlti_ref_date(config = task_config)

# Write out recoded and cleaned data ----
walk2(
    list_input_files_df,
    file.path(task_output_dir, paste0(task_input_files, ".feather")),
    write_feather
)
