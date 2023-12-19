TASK_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
META_TASK := gen_reports

include ../../config.mk

META_TASK_DIR := $(addprefix $(PROJECT_DIR)/,$(META_TASK))
SRC = $(TASK_DIR)/src/gen_reports_controller.R
GENERAL_FNS = ../../R/general_functions.R
INPUT_MOD_TABLES := $(addprefix $(META_TASK_DIR)/$\
	gen_model_tables/output/table_,\
	$(addsuffix .feather, 5 6 8 9 10 a2))
INPUT_PLOTS := $(addprefix $(META_TASK_DIR)/$\
	gen_plots/output/table_,\
	$(addsuffix _plot_grid.png, 5 6 8 9 10 a2))

# Input(s) took out input_plots
TASK_CONFIG = $(TASK_DIR)/hand/config.yml
TASK_FNS = $(wildcard $(TASK_DIR)/R/*.R)
IN_FILES = $(INPUT_MOD_TABLES) $(TASK_DIR)/src/gen_report_doc.R

# Output(s)
OUT_FILE = $(OUT_DIR)/forums_report.pdf

## report           : Generate report.
.PHONY : report
report : $(OUT_FILE)

$(OUT_FILE) : $(SRC) $(GENERAL_FNS) $(TASK_FNS) $(TASK_CONFIG) $(IN_FILES)
	$(R_script) --vanilla $<

## clean            : Remove auto-generated files.
.PHONY : clean
clean :
	rm -r $(OUT_DIR)

## variables        : List variables
.PHONY : variables
variables :
	@echo PROJECT_DIR: $(PROJECT_DIR)
	@echo TASK_DIR: $(TASK_DIR)
	@echo META_TASK_DIR: $(META_TASK_DIR)
	@echo IN_FILES: $(IN_FILES)
	@echo SRC: $(SRC)
	@echo TASK_FNS: $(TASK_FNS)
	@echo TASK_CONFIG: $(TASK_CONFIG)
	@echo OUT_FILE: $(OUT_FILE)


.PHONY : help
help : makefile
	@sed -n 's/^##//p' $<
