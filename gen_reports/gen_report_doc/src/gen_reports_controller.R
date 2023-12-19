# Ensure pacman is installed before attempting to use it ----
if (!require("pacman")) install.packages("pacman"); library(pacman)

# Load necessary packages for task ----
pacman::p_load(rmarkdown, yaml)

# Load general and/or task specifc functions ----
source(file.path("..", "..", "R", "general_functions.R"))

# Check for existence of and/or create task output directory ----
task_output_dir <- file.path("output")
check_create_dir(task_output_dir)

# Read in config file specifying unique decisions made for this task ----
task_config <- yaml::read_yaml(file.path("hand", "config.yaml"))

# Render report ----
rmarkdown::render(
    input = task_config$render_input,
    output_format = task_config$render_output_format,
    output_file = task_config$render_output_file,
    knit_root_dir = task_config$render_knit_root_dir,
    output_dir = task_config$render_output_dir
)
