TASK_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PREV_TASK1 := create_arrest_incidents_table
PREV_TASK2 := clean_universe_table

include ../config.mk

PREV_TASK_DIR1 := $(PROJECT_DIR)/$(PREV_TASK1)
PREV_TASK_DIR2 := $(PROJECT_DIR)/$(PREV_TASK2)

IN_DIR1 := $(PREV_TASK_DIR1)/output
IN_DIR2 := $(PREV_TASK_DIR2)/output

# Input(s)
PRIMARY_TASK_CONFIG = $(TASK_DIR)/hand/config.yml
TASK_FNS = $(wildcard $(TASK_DIR)/R/*.R)

IN_FILE1 = $(IN_DIR1)/arrest_incidents.feather
IN_FILE2 = $(IN_DIR2)/universe_table.feather

# Output(s)
OUT_FILE = $(OUT_DIR)/universe_table_covariates.feather

## generate_potential_covariates : Generate all potential covariates.
.PHONY : generate_potential_covariates
generate_potential_covariates : $(OUT_FILE)

$(OUT_FILE) : $(SRC) $(GENERAL_FNS) $(TASK_FNS) $(IN_FILE1) $(IN_FILE2)\
	$(PRIMARY_TASK_CONFIG)
	$(R_script) --vanilla $<

## clean                         : Remove auto-generated files.
.PHONY : clean
clean :
	rm -r $(OUT_DIR)

## variables                     : List variables
.PHONY : variables
variables :
	@echo PROJECT_DIR: $(PROJECT_DIR)
	@echo TASK_DIR: $(TASK_DIR)
	@echo SRC: $(SRC)
	@echo TASK_FNS: $(TASK_FNS)
	@echo IN_FILE1: $(IN_FILE1)
	@echo IN_FILE2: $(IN_FILE2)
	@echo OUT_FILE: $(OUT_FILE)


.PHONY : help
help : makefile
	@sed -n 's/^##//p' $<
