TASK_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
IN_DIR :=

include ../config.mk

# Input(s)
TASK_CONFIG = $(TASK_DIR)/hand/config.yml
IN_FILES = $(wildcard $(IN_DIR)/*/*.sav)

# Output(s)
OUT_FILES = $(OUT_DIR)/universe_table.feather

## universe_table : Create table of universe of cases.
.PHONY : universe_table
universe_table : $(OUT_FILES)

$(OUT_FILES) : $(SRC) $(GENERAL_FNS) $(IN_FILES) $(TASK_CONFIG)
	$(R_script) --vanilla $<

## clean          : Remove auto-generated files.
.PHONY : clean
clean :
	rm -r $(OUT_DIR)

## variables      : List variables
.PHONY : variables
variables :
	@echo PROJECT_DIR: $(PROJECT_DIR)
	@echo TASK_DIR: $(TASK_DIR)
	@echo IN_FILES: $(IN_FILES)
	@echo SRC: $(SRC)
	@echo OUT_FILES: $(OUT_FILES)

.PHONY : help
help : makefile
	@sed -n 's/^##//p' $<

