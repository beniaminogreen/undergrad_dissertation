# Undergrad Dissertation Repo
This is a Git repo to manage my dissertation work.

## Todo List:

- [x] Re-do directory structure
- [ ] Ensure scaling works for multiple keywords
- [ ] Add code to estimate placebo cutoff effects
- [x] Find expanded list of keywords
- [x] Write test assertions for R sinclair data cleaning
- [ ] Finish coding unit tests for python code
- [ ] Finish coding unit tests for analysis routines
- [x] Move manuscript over to Sweave
- [ ] Nest entire paper within a Docker container

## Replication with docker
### On Linux:
```
docker build -t dissertation_replication .
docker run --rm -v $PWD:/tmp/report dissertation_replication
```
### On Windows:
This part to come soon.
### On Mac:
This part to come soon.
