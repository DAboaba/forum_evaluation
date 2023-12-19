# Ensure pacman is installed before attempting to use it ----
if (!require("pacman")) install.packages("pacman"); library(pacman)

# Load necessary packages for task ----
pacman::p_load(yaml, here, readr, dplyr, lemon, stringr, feather, captioner)

# Load necessary general functions ----
source(file.path("..", "..", "R", "general_functions.R"))
source(file.path("R", "table_creation_functions.R"))

# Check for existence of and/or create task output directory ----
task_output_dir <- file.path("output")
check_create_dir(task_output_dir)

# Read in config file specifying unique decisions made for this task ----
task_config <- yaml::read_yaml(file.path("hand", "config.yaml"))
desired_tables <- task_config$desired_tables

# Specify previous task directories ----
previous_task_dirs <- here(task_config$previous_task_names)
task_input_dirs <- file.path(previous_task_dirs, "output")
names(task_input_dirs) <- paste0(c("regular"), "_models")

# Read in modeling grid with results ----
df_mod_specs_with_reg_results <- readr::read_rds(file.path(
    task_input_dirs[["regular_models"]],
    "model_specification_grid_with_results.rds")
)

df_model_results <- df_mod_specs_with_reg_results %>%
    select(Model = model_label,
           "Control mean" = control_mean,
           "Treatment Effect" = estimate,
           "p-value" = p.value,
           T.Statistic = statistic,
           "Std Error" = std.error,
           "Lower 95% Conf Int" = conf.low,
           "Upper 95% Conf Int" = conf.high,
           "Sample Size" = overall_nobs) %>%
    mutate(`Control mean` = as.numeric(`Control mean`))


tables <- df_model_results %>%
    recreate_multi_table(table_names = desired_tables,
                         config_with_models_for_table = task_config)

# Write out model tables ----
table_names <- names(tables) %>%
    str_replace_all(" ", "_") %>%
    str_to_lower()

walk2(tables,
      file.path(task_output_dir, paste0(table_names, ".feather")),
      write_feather)
