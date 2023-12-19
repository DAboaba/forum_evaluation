#' ---
#' geometry: margin=1.3cm
#' booktabs: true
#' header-includes:
#'  - \AtBeginDocument{\let\maketitle\relax}
#'  - \usepackage{threeparttable}
#'  - \usepackage{booktabs}
#'  - \usepackage{array}
#'  - \usepackage{caption}
#'  - \pagenumbering{gobble}
#' ---

## ----setup, include=FALSE-----------------------------------------------------
Sys.setenv(PATH = paste("", Sys.getenv("PATH"), sep = ":"))
knitr::opts_chunk$set(echo = FALSE, message = FALSE, warning = FALSE)
options(knitr.kable.NA = "-")

# Ensure pacman is installed before attempting to use it ----
if (!require("pacman")) install.packages("pacman"); library(pacman)

# Load necessary packages for task ----
pacman::p_load(yaml, here, feather)

# Load necessary general functions ----
source(file.path("..", "..", "R", "general_functions.R"))
source(file.path("R", "table_formatting_functions.R"))

# Read in config file specifying unique decisions made for this task ----
task_config <- yaml::read_yaml(file.path("hand", "config.yaml"))

# Specify previous task directories ----
previous_task_dirs <- here(task_config$previous_task_names)
task_input_dirs <- file.path(previous_task_dirs, "output")
names(task_input_dirs) <- paste0(c("cov", "mod", "plot"), "_dir")

# Read in model tables ----
mod_table_names <- c(
    paste0("table_", c(5, 6, 8:11, "a2", "10b", "6b", "8b", "9b")),
    paste0("table_", c(5, "a2"), "_truncated")
)

mod_table_paths <- file.path(
    task_input_dirs[["mod_dir"]],
    paste0(mod_table_names, ".feather")
)

mod_tables <- map(mod_table_paths, read_feather)
names(mod_tables) <- mod_table_names

## ---- Tables -------------------------------------------------------
format_table(
    list_with_component_tables = cov_tables,
    report_table_number = 1,
    grouping_var = "Location",
    config = task_config
)

#' \newpage

format_table(
    list_with_component_tables = cov_tables,
    report_table_number = 2,
    grouping_var = "cov_groupings",
    config = task_config
)

#' \newpage

format_table(
    list_with_component_tables = mod_tables,
    report_table_number = 3,
    config = task_config
)

#' \newpage

format_table(
    list_with_component_tables = mod_tables,
    report_table_number = 4,
    config = task_config
)

#' \newpage

format_table(
    list_with_component_tables = mod_tables,
    report_table_number = "4b",
    config = task_config
)

#' \newpage

format_table(
    list_with_component_tables = mod_tables,
    report_table_number = 5,
    config = task_config
)

#' \newpage

format_table(
    list_with_component_tables = mod_tables,
    report_table_number = "5b",
    config = task_config
)

#' \newpage

format_table(
    list_with_component_tables = mod_tables,
    report_table_number = 6,
    config = task_config
)

#' \newpage

format_table(
    list_with_component_tables = mod_tables,
    report_table_number = "6b",
    config = task_config
)

#' \newpage

format_table(
    list_with_component_tables = mod_tables,
    report_table_number = 7,
    config = task_config
)

#' \newpage

format_table(
    list_with_component_tables = mod_tables,
    report_table_number = 8,
    config = task_config
)
