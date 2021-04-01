# Undergrad Dissertation Repo
This is a Git repo to manage my dissertation work.

## Todo List Week of April 7th:

- [ ] Write rationale for using Google Trends as a proxy measure of racial animus
- [ ] Write current literature section (balance moving away from CARS with fufilling requirements for section)
- [ ] Create ``heatmap" to show which DMAs Sinclair moves into / out of
- [ ] Run tests on random data to confirm that scaling is necessary or figure out a way to articulate that it is
- [ ] Consider estimating average marginal treatment effects.
- [ ] Consider running MC power analysis (stretch goal)

## Todo List Week of April 1st:

- [x] Re-do directory structure
- [ ] Ensure scaling works for multiple keywords
- [x] Add code to estimate placebo cutoff effects
- [x] Find expanded list of keywords
- [x] Write test assertions for R Sinclair data cleaning
- [x] Finish coding unit tests for python code
- [x] Finish coding unit tests for analysis routines
- [x] Move manuscript over to Sweave
- [x] Figure out Udunits2 install on Docker
- [x] Nest entire paper within a Docker container
- [ ] Write Docstrings For Python Functions

## Replication With Docker
### [On](On) Linux:
```
docker build -t dissertation_replication .
docker run --rm -v $PWD:/opt/report dissertation_replication
```
### On Windows:
### On Mac:
