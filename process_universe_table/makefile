TASK_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PREV_TASK := create_universe_table

include ../config.mk

IN_DIR := $(PREV_TASK_DIR)/output

# Input(s)
PRIMARY_TASK_CONFIG = $(TASK_DIR)/hand/config.yml
SEC_TASK_CONFIGS = $(wildcard $(TASK_DIR)/hand/codebooks/*.yml)
TASK_FNS = $(wildcard $(TASK_DIR)/R/*.R)
IN_FILE = $(IN_DIR)/universe_table.feather

# Output(s)
OUT_FILE = $(OUT_DIR)/universe_table.feather

## process_universe_table : Recode and create new features in universe table.
.PHONY : process_universe_table
process_universe_table : $(OUT_FILE)

$(OUT_FILE) : $(SRC) $(GENERAL_FNS) $(TASK_FNS) $(IN_FILE)\
$(PRIMARY_TASK_CONFIG) $(SEC_TASK_CONFIGS)
	$(R_script) --vanilla $<

## clean                : Remove auto-generated files.
.PHONY : clean
clean :
	rm -r $(OUT_DIR)

## variables            : List variables
.PHONY : variables
variables :
	@echo PROJECT_DIR: $(PROJECT_DIR)
	@echo TASK_DIR: $(TASK_DIR)
	@echo SRC: $(SRC)
	@echo IN_FILE: $(IN_FILE)
	@echo TASK_FNS: $(TASK_FNS)
	@echo OUT_FILE: $(OUT_FILE)

.PHONY : help
help : makefile
	@sed -n 's/^##//p' $<
