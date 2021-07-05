# Undergrad Dissertation Repo

This is a repository which contains replication materials for my undegraduate dissertation. 
Since writing the paper, I have come to read more about the implicit association test (IAT) and 
the google search indexes used in the paper and am no longer confident in their ability to measure racial animus in a given area, 
so I would not take the (null) results in this paper as evidence for (the lack of) any trends in racial animus. The repository will remain public in line with the UCL regulations on undergraduate dissertations until 2022. 


Please follow the steps below if you are interested in re-running the code used to generate the paper.

## Replication With Docker
Using either git in the command line, or the download button above, clone this repository and navigate into it.

Then, depending on your system, run the following commands.

### Using Linux / Mac / Windows Power Shell:
```
docker build -t dissertation_replication .
docker run --rm -v ${PWD}:/opt/report dissertation_replication
```
### Using Windows Command Line:
```
docker build -t dissertation_replication .
docker run --rm -v  %cd%:/opt/report dissertation_replication
```
The first command could take around 40 minutes as installing the necessary R packages is slow.
The next command should run in under 40 minutes.
Once both have run, you should find a newly-generated copy of the report, ```diss.pdf``` in the ```diss/``` directory.

Hope you enjoy!
