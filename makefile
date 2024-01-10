## all                          : Run all tasks in this pipeline
all:
	cd create_violation_incidents_table && make
	cd create_arrest_incidents_table && make
	cd create_universe_table && make

	cd process_universe_table && make
	cd gen_treat_tract_crosswalks && make

	cd gen_potential_covariates && make
	cd gen_outcomes && make

	cd run_models && make

	cd gen_reports/gen_model_tables && make
	cd gen_reports/gen_plots && make
	cd gen_reports/gen_report_doc && make


## incident_and_universe_tables : Create incident and universe tables
incident_and_universe_tables:
	cd create_violation_incidents_table && make
	cd create_arrest_incidents_table && make
	cd create_universe_table && make

## data_prep                    : Run all data preparation tasks
data_prep:
	cd process_universe_table && make
	cd gen_potential_covariates && make
	cd gen_outcomes && make

## treatment_tract_crosswalks   : Generate crosswalks linking treatment and tract
treatment_tract_crosswalks:
	cd create_violation_incidents_table && make
	cd create_arrest_incidents_table && make
	cd create_universe_table && make
	cd process_universe_table && make
	cd gen_treat_tract_crosswalks && make

## model                        : Run all modeling tasks
model:
	cd create_violation_incidents_table && make
	cd create_arrest_incidents_table && make
	cd create_universe_table && make
	cd process_universe_table && make
	cd gen_potential_covariates && make
	cd gen_outcomes && make
	cd run_models && make

## report_components            : Run all tasks that output report components
report_components::
	cd create_violation_incidents_table && make
	cd create_arrest_incidents_table && make
	cd create_universe_table && make
	cd process_universe_table && make
	cd gen_potential_covariates && make
	cd gen_outcomes && make
	cd run_models && make
	cd gen_reports/gen_model_tables && make

## report                       : Generate the actual report
report:
	cd create_violation_incidents_table && make
	cd create_arrest_incidents_table && make
	cd create_universe_table && make
	cd process_universe_table && make
	cd gen_potential_covariates && make
	cd gen_outcomes && make
	cd run_models && make
	cd gen_reports/gen_model_tables && make
	cd gen_reports/gen_report_doc && make

## clean                        : Remove ALL auto-generated files
.PHONY : clean
clean :
	rm -r */output
	rm -r */*/output


.PHONY : help
help : makefile
	@sed -n 's/^##//p' $<
