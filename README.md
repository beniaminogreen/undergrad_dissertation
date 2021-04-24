# Undergrad Dissertation Repo
Welcome to the repo of replication materials for my undergraduate dissertation!
Please follow the steps below if you are interested in re-running the code used to generate the paper.

## Replication With Docker
Using either git in the command line, or the download button above, clone this repository and navigate into it.

Then, depending on your system, run the following commands.

### [On](On) Linux / Mac / Windows Power Shell:
```
docker build -t dissertation_replication .
docker run --rm -v ${PWD}:/opt/report dissertation_replication
```
### Windows Command Line:
```
docker build -t dissertation_replication .
docker run --rm -v  %cd%:/opt/report dissertation_replication
```
The first command could take around 40 minutes to install as installing the necessary R packages is slow.
The next command should run in under 10 minutes.
Once both have run, you should find a newly-generated copy of the report, ```diss.pdf``` in the ```diss``` directory.

Hope you enjoy!
