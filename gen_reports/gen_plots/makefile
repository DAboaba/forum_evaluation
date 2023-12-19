TASK_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PREV_TASK := generate_reports/generate_model_tables

include ../../config.mk

IN_DIR := $(PREV_TASK_DIR)/output
GENERAL_FNS = ../../R/general_functions.R

# Input(s)
PRIMARY_TASK_CONFIG = $(TASK_DIR)/hand/config.yml
TASK_FNS = $(wildcard $(TASK_DIR)/R/*.R)
IN_FILES = $(addsuffix .feather,\
							$(addprefix $(IN_DIR)/,\
								$(addprefix table_,5 6 8 9 10 11 a2)))

# Output(s)
OUT_FILES = $(addsuffix .jpg,\
              $(addprefix $(OUT_DIR)/,\
                itt tot spillover subgroup))

## plots      : Generate plots
.PHONY : plots
plots : $(OUT_FILES)

$(OUT_FILES) : $(SRC) $(GENERAL_FNS) $(TASK_FNS) $(PRIMARY_TASK_CONFIG)\
 $(IN_FILES)
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
	@echo SRC: $(SRC)
	@echo TASK_FNS: $(TASK_FNS)
	@echo PRIMARY_TASK_CONFIG: $(PRIMARY_TASK_CONFIG)
	@echo IN_FILES: $(IN_FILES)
	@echo OUT_FILES: $(OUT_FILES)


.PHONY : help
help : makefile
	@sed -n 's/^##//p' $<
