# Ensure pacman is installed before attempting to use it ----
if (!require("pacman")) install.packages("pacman"); library(pacman)

# Load necessary packages for script ----
pacman::p_load(dplyr, magrittr, forcats)

# Load necessary general functions ----
source(file.path("..", "R", "general_functions.R"))

recode_mearstat <- function(df) {
    df %>%
        recode_column_with_codebook(var_name = "mearstat") %>%
        mutate(mearstat = fct_explicit_na(mearstat))
}
