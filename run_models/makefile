TASK_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PREV_TASK1 := gen_potential_covariates
PREV_TASK2 := gen_outcomes

include ../config.mk

PREV_TASK_DIR1 := $(PROJECT_DIR)/$(PREV_TASK1)
PREV_TASK_DIR2 := $(PROJECT_DIR)/$(PREV_TASK2)
IN_DIR1 := $(PREV_TASK_DIR1)/output
IN_DIR2 := $(PREV_TASK_DIR2)/output

# Input(s)
TASK_AND_MODEL_CONFIGS = $(wildcard $(TASK_DIR)/hand/*.yml)
TASK_FNS = $(wildcard $(TASK_DIR)/R/*.R)
IN_FILE1 = $(IN_DIR1)/universe_table_covariates.feather
IN_FILE2 = $(IN_DIR2)/universe_table_outcomes.feather

# Output(s)
OUT_FILE1 = $(OUT_DIR)/model_specification_grid_with_results.rds
OUT_FILE2 = $(OUT_DIR)/covs_and_outcomes.feather

## run_models : Run all specified models.
.PHONY : run_models
run_models : $(OUT_FILE1) $(OUT_FILE2)

$(OUT_FILE1) : $(SRC) $(GENERAL_FNS) $(TASK_FNS) $(TASK_AND_MODEL_CONFIGS)\
	$(IN_FILE1) $(IN_FILE2)
	$(R_script) --vanilla $<

$(OUT_FILE2) : $(SRC) $(GENERAL_FNS) $(TASK_FNS) $(TASK_AND_MODEL_CONFIGS)\
	$(IN_FILE1) $(IN_FILE2)
	$(R_script) --vanilla $<

## clean      : Remove auto-generated files.
.PHONY : clean
clean :
	rm -r $(OUT_DIR)

## variables  : List variables
.PHONY : variables
variables :
	@echo PROJECT_DIR: $(PROJECT_DIR)
	@echo TASK_DIR: $(TASK_DIR)
	@echo TASK_FNS: $(TASK_FNS)
	@echo SRC: $(SRC)
	@echo TASK_AND_MODEL_CONFIGS: $(TASK_AND_MODEL_CONFIGS)
	@echo IN_FILE1: $(IN_FILE1)
	@echo IN_FILE2: $(IN_FILE2)
	@echo OUT_FILE1: $(OUT_FILE1)
	@echo OUT_FILE2: $(OUT_FILE2)


.PHONY : help
help : makefile
	@sed -n 's/^##//p' $<
