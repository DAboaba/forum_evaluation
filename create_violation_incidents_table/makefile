TASK_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
IN_DIR :=

include ../config.mk

# Input(s)
TASK_CONFIG = $(TASK_DIR)/hand/config.yaml
EXTRA_CONFIGS =  $(wildcard $(TASK_DIR)/hand/codebooks/*.yaml)
TASK_FNS = $(wildcard $(TASK_DIR)/R/*.R)
IN_FILE = $(IN_DIR)/

# Output(s)
OUT_FILE = $(OUT_DIR)/violation_incidents.feather

## violation_incidents_table : Create table of violation incidents
.PHONY : violation_incidents_table
violation_incidents_table : $(OUT_FILE)

$(OUT_FILE) : $(SRC) $(GENERAL_FNS) $(TASK_FNS) $(IN_FILE) $(TASK_CONFIG) $\
	$(EXTRA_CONFIGS)
	$(R_script) --vanilla $<

## clean                     : Remove auto-generated files.
.PHONY : clean
clean :
	rm -r $(OUT_DIR)

## variables                 : List variables.
.PHONY : variables
variables :
	@echo PROJECT_DIR: $(PROJECT_DIR)
	@echo TASK_DIR: $(TASK_DIR)
	@echo TASK_FNS: $(TASK_FNS)
	@echo IN_FILE: $(IN_FILE)
	@echo EXTRA_CONFIGS: $(EXTRA_CONFIGS)
	@echo SRC: $(SRC)
	@echo OUT_FILE: $(OUT_FILE)

.PHONY : help
help : makefile
	@sed -n 's/^##//p' $<
