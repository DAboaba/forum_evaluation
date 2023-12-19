# Ensure pacman is installed before attempting to use it ----
if (!require("pacman")) install.packages("pacman"); library(pacman)

# Load necessary packages for script ----
pacman::p_load(purrr, magrittr, knitr, kableExtra)

# convert tables to properly customized  for printing
format_table <- function(list_with_component_tables,
                         report_table_number,
                         grouping_var = "outcome_group",
                         config) {

    # build table name for detail retrieval
    table_name <- paste0("table_", report_table_number)

    # modify config to make data retrieval easier
    config <- config[[table_name]]

    num_comp_tables <- length(config$comp_tables)
    comp_tables <- list_with_component_tables[config$comp_tables]

    # take one set of outcome groupings
    outcome_groupings <- comp_tables[[1]][[grouping_var]]

    # remove empty groupings
    outcome_groupings <- outcome_groupings[outcome_groupings != ""]

    # tables sometimes have extra columns to remove
    extra_cols_to_remove <- c(grouping_var, "Model", "within_group_order",
                              "Lower 95% Conf Int", "Upper 95% Conf Int")

    # if we're combining two tables we need to combine them in specific ways to
    # get rid of duplicate cols
    if (num_comp_tables > 1) {
        first_table <- comp_tables[[1]] %>% select(-any_of(extra_cols_to_remove))
        second_table <- comp_tables[[2]] %>% select(-any_of(extra_cols_to_remove))

        first_c_means <- first_table[["Control mean"]]
        second_c_means <- second_table[["Control mean"]]

        if (identical(first_c_means, second_c_means)) {
            cols_to_remove <- c("Control mean", "Outcome")
        } else if (!identical(first_c_means, second_c_means)) {
            cols_to_remove <- c("Outcome")
        }

        # take correct set of column names
        colnames_table_to_format <- c(
            colnames(first_table),
            colnames(second_table %>% select(-all_of(cols_to_remove)))
        )


        # combine multiple tables
        table_to_format <- bind_cols(
            first_table,
            second_table %>% select(-all_of(cols_to_remove))
        )


        # assign column names
        colnames(table_to_format) <- colnames_table_to_format
    } else {
        table_to_format <- comp_tables[[1]] %>%
            select(-any_of(extra_cols_to_remove))
    }

    # create note depnding on presence of signifcant results
    if (any(grepl("\\*", table_to_format[["Treatment Effect"]]))) {
        config$note <- paste(
            config$note,
            "Asterisks denote the level of statistical significance
                         of the estimate as follows: *** = p-value < 0.01, ** =
                         p-value < 0.05, * = p-value < 0.1"
        )
    }

    note <- gsub("\n", " ", config$note)

    kable_table <- kable(table_to_format,
                         format = "latex",
                         caption = config$caption,
                         align = config$align,
                         linesep = " ",
                         booktabs = TRUE) %>%
        kable_styling(latex_options = "hold_position",
                      full_width = FALSE,
                      font_size = 9) %>%
        footnote(general = eval(note),
                 threeparttable = TRUE,
                 general_title = "Notes:") %>%
        row_spec(config$row_spec_rows, hline_after = TRUE)

    column_specs <- config$column_spec
    for (i in seq_len(length(column_specs$width))) {
        kable_table %<>%
            column_spec(column = i,
                        width = paste0(column_specs$width[i], column_specs$unit))
    }

    pack_rows_labels <- unique(outcome_groupings)

    for (i in seq_len(length(pack_rows_labels))) {
        if (pack_rows_labels[i] == "NA") {
            kable_table
        } else {
            pack_row_label_start <- first(grep(pack_rows_labels[i], outcome_groupings))
            pack_row_label_end <- last(grep(pack_rows_labels[i], outcome_groupings))

            kable_table %<>%
                pack_rows(group_label = pack_rows_labels[i],
                          start_row = pack_row_label_start,
                          end_row = pack_row_label_end)
        }
    }

    if (!is.null(config$header)) {
        header_colspan_vector <- config$header$colspan
        names(header_colspan_vector) <- config$header$labels
        kable_table %<>%
            add_header_above(header_colspan_vector)
    }

    kable_table
}
