## all                          : Run all tasks in this pipeline
all:
	cd create_violation_incidents_table && make
	cd create_arrest_incidents_table && make
	cd create_universe_table && make

	cd clean_universe_table && make
	cd generate_treatment_tract_crosswalks && make

	cd generate_potential_covariates && make
	cd generate_outcomes && make

	cd run_models && make

	cd generate_reports/generate_covariate_tables && make
	cd generate_reports/generate_model_tables && make
	cd generate_reports/generate_plots && make
	cd generate_reports/generate_report_doc && make


## incident_and_universe_tables : Create incident and universe tables
incident_and_universe_tables:
	cd create_violation_incidents_table && make
	cd create_arrest_incidents_table && make
	cd create_universe_table && make

## data_prep                    : Run all data preparation tasks
data_prep:
	cd clean_universe_table && make
	cd generate_potential_covariates && make
	cd generate_outcomes && make

## treatment_tract_crosswalks   : Generate crosswalks linking treatment and tract
treatment_tract_crosswalks:
	cd create_violation_incidents_table && make
	cd create_arrest_incidents_table && make
	cd create_universe_table && make
	cd clean_universe_table && make
	cd generate_treatment_tract_crosswalks && make

## model                        : Run all modeling tasks
model:
	cd create_violation_incidents_table && make
	cd create_arrest_incidents_table && make
	cd create_universe_table && make
	cd clean_universe_table && make
	cd generate_potential_covariates && make
	cd generate_outcomes && make
	cd run_models && make

## report_components            : Run all tasks that output report components
report_components::
	cd create_violation_incidents_table && make
	cd create_arrest_incidents_table && make
	cd create_universe_table && make
	cd clean_universe_table && make
	cd generate_potential_covariates && make
	cd generate_outcomes && make
	cd run_models && make
	cd generate_reports/generate_covariate_tables && make
	cd generate_reports/generate_model_tables && make

## report                       : Generate the actual report
report:
	cd create_violation_incidents_table && make
	cd create_arrest_incidents_table && make
	cd create_universe_table && make
	cd clean_universe_table && make
	cd generate_potential_covariates && make
	cd generate_outcomes && make
	cd run_models && make
	cd generate_reports/generate_covariate_tables && make
	cd generate_reports/generate_model_tables && make
	cd generate_reports/generate_report_doc && make

## clean                        : Remove ALL auto-generated files
.PHONY : clean
clean :
	rm -r */output
	rm -r */*/output


.PHONY : help
help : makefile
	@sed -n 's/^##//p' $<
