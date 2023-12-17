# Ensure pacman is installed before attempting to use it ----
if (!require("pacman")) install.packages("pacman"); library(pacman)

# Load necessary packages for script ----
pacman::p_load(dplyr, stringr)

create_arr_indicator_features <- function(df, config) {
    regex_arr_charge_types <- paste0(config[["arr.charge.types"]], collapse = "|")

    df %>%
        mutate(arr.indicator = 1,
               # Build weapon arrest indicator
               wea.arr.firearm.indicator = arr.firearm %in% config[["arr.firearm.types"]],
               wea.arr.charge.indicator = grepl(regex_arr_charge_types, arr.charge),
               wea.arr.520.charge.indicator = grepl(
                   config[["arr.charge.type.520"]],
                   str_sub(arr.charge, -3)),
               wea.arr.indicator = (
                   wea.arr.firearm.indicator == TRUE |
                       wea.arr.charge.indicator == TRUE |
                       wea.arr.520.charge.indicator == TRUE
               ),
               vfo.arr.indicator = arr.vfo %in% config[["arr.vfo.types"]])
}

