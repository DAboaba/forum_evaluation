TASK_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PREV_TASK := clean_universe_table

include ../config.mk

IN_DIR := $(PREV_TASK_DIR)/output

# Input(s)
TASK_CONFIG = $(TASK_DIR)/hand/config.yaml
IN_FILE = $(IN_DIR)/universe_table.feather

# Output(s)
OUT_FILES = $(addsuffix .feather, $(addprefix\
	$(OUT_DIR)/treatment_tract_crosswalk_, tract_lvl arrest_lvl))

## treatment_tract_crosswalks : Create crosswalk linking treatment and tract.
.PHONY : treatment_tract_crosswalks
treatment_tract_crosswalks : $(OUT_FILES)

$(OUT_FILES) : $(SRC) $(GENERAL_FNS) $(IN_FILE) $(TASK_CONFIG)
	$(R_script) --vanilla $<

## clean                      : Remove auto-generated files.
.PHONY : clean
clean :
	rm -r $(OUT_DIR)

## variables                  : List variables
.PHONY : variables
variables :
	@echo PROJECT_DIR: $(PROJECT_DIR)
	@echo TASK_DIR: $(TASK_DIR)
	@echo IN_FILE: $(IN_FILE)
	@echo SRC: $(SRC)
	@echo OUT_FILES: $(OUT_FILES)

.PHONY : help
help : makefile
	@sed -n 's/^##//p' $<
