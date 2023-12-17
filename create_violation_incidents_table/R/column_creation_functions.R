# Ensure pacman is installed before attempting to use it ----
if (!require("pacman")) install.packages("pacman"); library(pacman)

# Load necessary packages for script ----
pacman::p_load(magrittr, fastDummies, dplyr)

# Load general and/or task specifc functions ----
source(file.path("..", "R", "general_functions.R"))

create_pvio_indicator_features <- function(df) {
    df %>%
        dummy_features(specified_features = "WTYP") %>%
        rename(pvio_missing_indicator = `WTYP_(Missing)`,
               pvio.new.arr.indicator = `WTYP_new arrest`,
               pvio.abs.indicator = WTYP_absconder,
               pvio.tech.indicator = WTYP_technical) %>%
        mutate(pvio.indicator = if_else(pvio_missing_indicator != 1, 1, 0)) %>%
        mutate(across(starts_with("pvio"), as.logical))
}

