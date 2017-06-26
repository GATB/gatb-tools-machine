# Using GoDocker on the command-line

This document illustrates how to run *gatb\_tools\_machine* jobs on GoDocker from the command-line instead of the web interface.

# Requirements

* **python 2.7**. Should be available on both OSX or Linux
* [godocker_cli](https://bitbucket.org/osallou/go-docker-cli/).
    Should **not** be installed on OSX or Linux, so: do it!
* **bc** - An arbitrary precision calculator language. Available on OSX, can be missing on Linux, so use something like: sudo apt install bc.
* an account on [GoDocker](https://godocker.genouest.org)

# Tutorial: running a Simka job

## What?

So, you are going to run from the command-line a Simka job within a *gatb\_tools\_machine* instance running through GoDocker on the Genouest Bioinformatics platform... got it? ;-)

## How?

You need your GoDocker token. Log in to your GoDocker account, then click on your name (top right corner of the GoDocker web page): you'll see your profile where the first entry is the "API Token".

Then, go to the command-line on your local computer (no need to have a session on a Genouest machine):

```
cd gatb-tools-machine/godocker
./godocker-test-gtm.sh <godocker-login> <api-token> simka.sh
```

You should see something like:

```
Logging in to go-docker...
   OK
Submitting script 'simka.sh'...
   OK
Job started with ID: 7729
 resources requested: 4 cpu, 4 Gb RAM
Waiting for results... (120 sec at max; Refresh rate: 4.0 sec)
[==============================] [over]    
Getting gatb_tools_machine result file: gatb_tool_results.tgz ...
   OK
Getting running time...
   1 seconds
SUCCESS
```

Then, have a look at the result file:

```
tar -ztf gatb_tool_results.tgz 
simka_results/
simka_results/mat_presenceAbsence_chord.csv.gz
simka_results/mat_presenceAbsence_whittaker.csv.gz
simka_results/mat_presenceAbsence_kulczynski.csv.gz
simka_results/mat_presenceAbsence_braycurtis.csv.gz
simka_results/mat_presenceAbsence_jaccard.csv.gz
simka_results/mat_presenceAbsence_simka-jaccard.csv.gz
simka_results/mat_presenceAbsence_simka-jaccard_asym.csv.gz
simka_results/mat_presenceAbsence_ochiai.csv.gz
simka_results/mat_abundance_simka-jaccard.csv.gz
simka_results/mat_abundance_simka-jaccard_asym.csv.gz
simka_results/mat_abundance_ab-ochiai.csv.gz
simka_results/mat_abundance_ab-sorensen.csv.gz
simka_results/mat_abundance_ab-jaccard.csv.gz
simka_results/mat_abundance_braycurtis.csv.gz
simka_results/mat_abundance_jaccard.csv.gz
```
That's all folks!

## Want more?

GoDocker master script is: [godocker-run.sh](https://github.com/GATB/gatb-tools-machine/blob/master/godocker/godocker-run.sh). You should not modify that one much.

That script sends to the GoDocker server this one: [simka.sh](https://github.com/GATB/gatb-tools-machine/blob/master/godocker/simka.sh). This is the script you could modify to run another job, either Simka or any other GATB-Tools available within *gatb\_tools\_machine*.
