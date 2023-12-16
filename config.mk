PROJECT_DIR := $(shell git rev-parse --show-toplevel)
PREV_TASK_DIR := $(PROJECT_DIR)/$(PREV_TASK)
SRC = $(wildcard $(TASK_DIR)/src/*.R)
GENERAL_FNS := ../R/general_functions.R
OUT_DIR := $(TASK_DIR)/output
R_script = /usr/local/bin/Rscript
