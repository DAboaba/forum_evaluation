# Ensure pacman is installed before attempting to use it ----
if (!require("pacman")) install.packages("pacman"); library(pacman)

# Load necessary packages for script ----
pacman::p_load(magrittr, dplyr, forcats)

recode_wtyp_col <- function(df) {
    df %>%
        recode_column_with_codebook(var_name = "WTYP") %>%
        mutate(WTYP = fct_explicit_na(WTYP))
}
