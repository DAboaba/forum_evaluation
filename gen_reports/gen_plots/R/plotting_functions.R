# Ensure pacman is installed before attempting to use it ----
if (!require("pacman")) install.packages("pacman"); library(pacman)

# Load necessary packages for script ----
pacman::p_load(magrittr, dplyr, purrr, ggplot2, cowplot)

plot_result_outcome_group <- function(model_table,
                                      chosen_outcome_groups,
                                      alt,
                                      analysis,
                                      up_lim,
                                      low_lim,
                                      incr) {
    # now working on streamlinging this
    plot_table <- plot_table_prep(model_table, chosen_outcome_groups, alt)

    plt <- plot_table %>%
        ggplot() +
        geom_hline(aes(yintercept = 0), color = "black", linetype = "dashed")

    if (alt) {
        plt <- plt +
            geom_errorbar(aes(
                x = outcome_group,
                ymin = rel_lower_conf_int,
                ymax = rel_upper_conf_int
            ),
            color = "#767676",
            width = 0.1
            ) +
            geom_point(aes(
                x = outcome_group,
                y = rel_treat_eff,
                fill = Significance
            ),
            size = 3,
            shape = 21,
            color = "black"
            ) +
            ylab("Treatment Effect (%)") +
            xlab("Outcome")
    } else {

        xlabel <- "Time Window (months)"

        plt <- plt +
            geom_errorbar(aes(
                x = Outcome,
                ymin = rel_lower_conf_int,
                ymax = rel_upper_conf_int
            ),
            color = "#767676",
            width = 0.1
            ) +
            geom_point(aes(
                x = Outcome,
                y = rel_treat_eff,
                fill = Significance
            ),
            size = 3,
            shape = 21,
            color = "black"
            ) +
            ylab("Treatment Effect (%)") +
            xlab(xlabel)
    }

    brks <- seq(low_lim, up_lim, incr)
    lbls <- paste0(brks, "%")

    plt <- plt +
        scale_y_continuous(
            limits = c(low_lim, up_lim),
            breaks = brks,
            labels = lbls
        ) +
        scale_fill_manual(
            name = "Significance Level",
            labels = c("> 0.1", "0.1", "0.05", "0.01"),
            values = c("white", "#cc9999", "#a64c4c", "#800000"),
            drop = FALSE
        )

    if (alt) {
        plt <- plt + facet_wrap(vars(subgroup))
    } else {
        plt <- plt + facet_wrap(vars(outcome_group))
    }

    plt +
        theme(panel.grid.minor.y = element_blank(),
              panel.grid.major.x = element_blank(),
              panel.spacing = unit(c(1), "lines"),
              legend.position = "bottom",
              legend.key = element_blank(),
              axis.title.x = element_text(size = 14, margin = margin(t = 10)),
              axis.title.y = element_text(size = 14, margin = margin(r = 10)),
              axis.ticks = element_blank(),
              axis.text = element_text(size = 12),
              strip.text = element_text(size = 14),
              panel.background = element_rect(color = "black"),
              strip.background = element_rect(color = "black"),
              legend.text = element_text(size = 12),
              legend.title = element_text(size = 14))
}

plot_table_prep <- function(model_table, chosen_outcome_groups, alt = FALSE) {
    if (alt) {
        model_table %<>%
            unite(outcome_full, Outcome, outcome_group, sep = " ", remove = FALSE) %>%
            mutate(outcome_group = outcome_full,
                   outcome_full = NULL,
                   subgroup = factor(subgroup,
                                     levels = c("Under Age 30", "At Least 2 Weapons Charges")))
    }

    if (!("subgroup" %in% colnames(model_table))) {
        model_table %<>%
            mutate(Outcome = factor(Outcome,
                                    levels = c(
                                        "Within 3 months", "Within 6 months",
                                        "Within 1 year", "Within 2 years",
                                        "Any"
                                    ),
                                    labels = c(3, 6, 12, 24, "Any"))
                   )
    }

    model_table %>%
        mutate(
            outcome_group = factor(
                outcome_group,
                levels = c(
                    "All Arrests", "All Complaints", "All Shootings",
                    "Violent Felony Arrests", "All Violations", "Arrest Violations",
                    "New Arrest Violations", "Absconding Violations",
                    "Technical Violations"
                )
            ),
            Significance = str_count(`Treatment Effect`, "\\*"),
            Significance = factor(Significance, levels = c(0, 1, 2, 3)),
            `Treatment Effect` = str_remove_all(`Treatment Effect`, "\\*"),
            across(
                !any_of(c(
                    "Outcome", "outcome_group", "Model",
                    "within_group_order", "sugbroup", "Significance"
                )),
                as.numeric
            ),
            rel_treat_eff = (`Treatment Effect` / `Control mean`) * 100,
            rel_lower_conf_int = (`Lower 95% Conf Int` / `Control mean`) * 100,
            rel_upper_conf_int = (`Upper 95% Conf Int` / `Control mean`) * 100
        ) %>%
        filter(outcome_group %in% chosen_outcome_groups)
}
