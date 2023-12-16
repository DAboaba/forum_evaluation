# FORUM EVALUATION
This repo contains code used to evaluate a criminal-justice forum

To run the pipeline:

Clone the repo:
1. `cd desired_directory`
2.  `git clone` the SSH clone url

To run the code on your local machine:
1. Set your working directory to the root of the project folder
	- At terminal: `cd parole_forums`
	- In Rstudio console: `setwd("../parole_forums")`

2. Confirm your working directory is at the root of the project directory
	- At terminal: `pwd`
	- In Rstudio console: `getwd()`

3. Run entire pipeline
	- Automagically: `make all`

4. Singular task(s)
	- Automatically
		- At command line, `cd task-name && make all`
	- Manually
		- In Rstudio console, `setwd("task-name"); source("src/task-name.r")`

To test that code works:
1. Do as above
2. Do as above
3. Run entire pipeline: Replace above with `make clean && make all`
4. Singular task(s):
    - Automatically: Replace above with `cd task-name && make clean && make all`
    - Manually: Replace above with `setwd("task-name"); unlink("output", recursive = TRUE); source("src/task-name.r")`

Replace "task-name" with name of relevant task

Further explanation:
At any level of project, use `make help` to learn about other helpful make commands you can run.
