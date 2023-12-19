TASK_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

PREV_TASK1 := create_violation_incidents_table
PREV_TASK2 := create_arrest_incidents_table
PREV_TASK3 := clean_universe_table

include ../config.mk

#PREV_TASK_DIRS := $(addprefix $(PROJECT_DIR)/$(PREV_TASKS))
PREV_TASK_DIR1 := $(PROJECT_DIR)/$(PREV_TASK1)
PREV_TASK_DIR2 := $(PROJECT_DIR)/$(PREV_TASK2)
PREV_TASK_DIR3 := $(PROJECT_DIR)/$(PREV_TASK3)

IN_DIR1 := $(PREV_TASK_DIR1)/output
IN_DIR2 := $(PREV_TASK_DIR2)/output
IN_DIR3 := $(PREV_TASK_DIR3)/output

# Input(s)
TASK_CONFIGS = $(wildcard $(TASK_DIR)/hand/*.yml)
TASK_FNS = $(wildcard $(TASK_DIR)/R/*.R)
IN_FILE1 = $(IN_DIR1)/violation_incidents.feather
IN_FILE2 = $(IN_DIR2)/arrest_incidents.feather
IN_FILE3 = $(IN_DIR3)/universe_table.feather

# Output(s)
OUT_FILE = $(OUT_DIR)/universe_table_outcomes.feather

## generate_outcomes             : Generate all outcomes.
.PHONY : generate_outcomes
generate_outcomes : $(OUT_FILE)

$(OUT_FILE) : $(SRC) $(GENERAL_FNS) $(TASK_FNS) $(IN_FILE1) $(IN_FILE2) $(IN_FILE3) $(TASK_CONFIGS)
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
	@echo TASK_CONFIGS: $(TASK_CONFIGS)
	@echo IN_FILE1: $(IN_FILE1)
	@echo IN_FILE2: $(IN_FILE2)
	@echo IN_FILE3: $(IN_FILE3)
	@echo OUT_FILE: $(OUT_FILE)
	@echo PREV_TASKS: $(PREV_TASKS)


.PHONY : help
help : makefile
	@sed -n 's/^##//p' $<
