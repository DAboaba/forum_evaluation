# Ensure pacman is installed before attempting to use it ----
if (!require("pacman")) install.packages("pacman"); library(pacman)

# Load necessary packages for task ----
pacman::p_load(magrittr, yaml, here, feather, dplyr, ggplot2)

# Load necessary general functions ----
source(file.path("..", "..", "R", "general_functions.R"))
source(file.path("R", "plotting_functions.R"))

# Check for existence of and/or create task output directory ----
task_output_dir <- file.path("output")
check_create_dir(task_output_dir)

# Read in config file specifying unique decisions made for this task ----
task_config <- yaml::read_yaml(file.path("hand", "config.yml"))

# Specify previous task directories ----
previous_task_dir <- here(task_config$previous_task_name)
task_input_dir <- file.path(previous_task_dir, "output")

# Specify name of input files ----
task_input_files <- paste0("table_", c(5:6, 8:10, "a2"))

# Specify path of input files ----
task_input_files_path <- file.path(task_input_dir,
                                   paste0(task_input_files, ".feather"))

# Read in pat's tables from previous task ----
tables <- map(task_input_files_path, read_feather)
names(tables) <- task_input_files

plots <- list()

plots[["itt"]] <- plot_result_outcome_group(
    tables$table_5,
    c("All Arrests", "All Violations", "Absconding Violations"),
    alt = FALSE,
    analysis = "itt",
    up_lim = 50,
    low_lim = -100,
    incr = 50
)

plots[["tot"]] <- plot_result_outcome_group(
    tables$table_a2,
    c("All Arrests", "All Violations", "Absconding Violations"),
    alt = FALSE,
    analysis = "tot",
    up_lim = 50,
    low_lim = -100,
    incr = 50
)

plots[["spillover"]] <- plot_result_outcome_group(
    tables$table_10,
    c("All Arrests", "Violent Felony Arrests", "All Violations"),
    alt = FALSE,
    analysis = "spillover",
    up_lim = 180,
    low_lim = -100,
    incr = 100
)

plots[["subgroup"]] <- bind_rows(
    tables$table_6 %>% mutate(subgroup = "Under Age 30"),
    tables$table_8 %>% mutate(subgroup = "At Least 2 Weapons Charges")) %>%
    plot_result_outcome_group(
        c("All Arrests", "Violent Felony Arrests", "All Violations"),
        alt = TRUE,
        analysis = "subgroup",
        up_lim = 200,
        low_lim = -50,
        incr = 50
    )

# Write out plots ----
walk2(.x = file.path(task_output_dir, paste0(names(plots), ".jpg")),
      .y = plots,
      ggsave,
      width = 10.5,
      height = 6.28)
