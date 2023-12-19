# Ensure pacman is installed before attempting to use it ----
if (!require("pacman")) install.packages("pacman"); library(pacman)

# Load necessary packages for task ----
pacman::p_load(yaml, here, purrr, feather, dplyr, magrittr, readr)

# Load general and/or task specifc functions ----
source(file.path("..", "R", "general_functions.R"))
source(file.path("R", "modeling_functions.R"))

# Check for existence of and/or create task output directory ----
task_output_dir <- file.path("output")
check_create_dir(task_output_dir)

# Read in config file specifying unique decisions made for this task ----
task_config_path <- file.path("hand")
primary_task_config <- yaml::read_yaml(
    file.path(task_config_path, "primary_config.yaml")
)

# Specify previous task directories ----
previous_task_dir <- here(primary_task_config$previous_task_name)
task_input_dir <- file.path(previous_task_dir, "output")

# Specify name of input files ----
task_input_files <- c(
    "universe_table_covariates",
    "universe_table_outcomes"
)

# Specify path of input files ----
task_input_files_path <- file.path(
    task_input_dir,
    paste0(task_input_files, ".feather")
)

# Read in incident and universe tables from previous task ----
list_input_files_df <- map(task_input_files_path, read_feather)
names(list_input_files_df) <- task_input_files

# Join the two dfs ----
df_covs_and_outcomes <- full_join(
    list_input_files_df$universe_table_covariates,
    list_input_files_df$universe_table_outcomes,
    by = "new.nysid"
)


# Create modeling grid for all models ----
df_grid_of_mod_specs <- evaluate_multiple_model_grids(
    task_config_path
)

# Add regression models to created modeling grid ----
df_mod_specs_with_reg_models <- add_regression_models_to_grid(
    df_covs_and_outcomes,
    df_grid_of_mod_specs
)

# Tidy_models_from_grid fn doesn't work for both ols and 2sls models
# Add regression results to modified modeling grid ----

df_mod_specs_ols_results <- tidy_models_from_grid(
    df_mod_specs_with_reg_models %>% filter(model_types != "2SLS"),
    model_types = "OLS"
)

df_mod_specs_2sls_results <- tidy_models_from_grid(
    df_mod_specs_with_reg_models %>%
        filter(model_types == "2SLS"),
    model_types = "2SLS"
)


df_mod_specs_with_reg_results <- bind_rows(
    df_mod_specs_ols_results,
    df_mod_specs_2sls_results
)


# Write out data and model results ----
write_feather(
    df_covs_and_outcomes,
    file.path(task_output_dir, "covs_and_outcomes.feather")
)

write_rds(
    df_mod_specs_with_reg_results,
    file.path(task_output_dir, "model_specification_grid_with_results.rds")
)
