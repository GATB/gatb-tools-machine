# *GATB-TOOLS* and *Docker*

This document explains how you can setup and use *GATB-Tools* within a Docker container.

## What are GATB-Tools?

**GATB-Tools** are softwares built upon the [GATB-Core Library](https://github.com/GATB/gatb-core/wiki). As of June 2017, these are:

*  [Simka](https://github.com/GATB/simka)
*  [DSK](https://github.com/GATB/dsk)
*  [BLOOCOO](https://github.com/GATB/bloocoo)
*  [MindTheGap](https://github.com/GATB/MindTheGap)
*  [Minia](https://github.com/GATB/minia)
*  [Short Read Connector](https://github.com/GATB/short_read_connector)
*  [DiscoSNP++](https://github.com/GATB/DiscoSnp)
*  [TakeABreak](https://github.com/GATB/TakeABreak)

## About this project

It aims at providing you with the material (i.e. a *Dockerfile*) to build a single Docker image containing all above mentioned GATB-Tools binaries. 

It is worth noting that this *Dockerfile* packages the latest available binary release of each GATB-Tool as it is available in the respective project. In other words, this *Dockerfile* **DOES NOT** compile anything.

## Requirements

Of course, you need to have [Docker](https://docs.docker.com/engine/installation/) installed on your system. 

We also suppose that you are familiar with [docker build](https://docs.docker.com/engine/reference/commandline/build/) and [docker run](https://docs.docker.com/engine/reference/commandline/run/) commands.

Note: provided *Dockerfile* was made and tested using *Docker version 17* on *Mac OSX Yosemite*. However, it should work on other releases of Docker and OS (Linux, Windows or OSX). 

# How to build the image?

## Build the image

    cd <some-working-directory>
    git clone https://github.com/GATB/gatb-tools-machine.git
    docker build -f Dockerfile -t gatb_tools_machine .
    
    # Do not forget ending '.': it is part of the docker build command

## Test the image

    docker run --rm -i -t gatb_tools_machine -c test

## Display list of available GATB-Tools

    docker run --rm -i -t gatb_tools_machine -c version

# How to use the image on the command-line?

General form of the command to use is as follows:

    docker run --rm -i -t gatb_tools_machine -c <command> -- <arguments>
    
    where:
        <command>: see ./run-tool.sh
        <arguments>: see ./run-tool.sh

## Example: running Simka

To illustrate the use of this GATB-Tools Docker Image, let's take the example of running SIMKA tool.

Command to run Simka is as follows:

    docker run --rm -i -t -v $PWD:/tmp gatb_tools_machine -c simka -- -in /opt/simka/example/simka_input.txt -out /tmp/simka_results/ -out-tmp /tmp/simka_temp_output

You should have Simka results in "$PWD/simka_results" directory when Simka job is done.
This command-line line explained:

    docker run                                 [1]
       --rm                                    [2]
       -i -t                                   [3]
       -v $PWD:/tmp                            [4]
       gatb_tools_machine                      [5] 
       -c simka                                [6]
       --                                      [7]
       -in /opt/simka/example/simka_input.txt  [8]
       -out /tmp/simka_results/                [9]
       -out-tmp /tmp/simka_temp_output         [10]
    
    [1]-[5]: Docker arguments
    [6]-[7]: simka container's invoker program
    [8]-[10]: 'bin/simka' arguments
    
    [1]: start Docker container
    [2]: destroy container when Docker finishes
         (it does NOT delete the 'gatb_tools_machine' image)
    [3]: start an interactive job 
         (for instance, you'll see messages on stdout, if any)
    [4]: mount a volume. This is required to get the results from Simka.
         Here, we say that current local directory will be viewed as '/tmp'
         from the inside of the container. 
    [5]: tell Docker which image to start: the 'gatb_tools_machine' of course.
    [6]: ask to start the simka program. See companion file 'run-tool.sh' for
         more information.
    [7]: '--' is required to separate arguments [6] from the rest of the
         command line
    [8]: the data file to process with simka. Here we use a data file
         provided with the simka software to test it.
    [9]: tells simka where to put results. Of course, simka will write 
         within /tmp directory inside the container. However, since we
         have directive [4], data writing is actually done in $PWD, i.e.
         a local directory.
    [10]: tells simka where to put temporary files. 

## Running other GATB-Tools

Please refer to the appropriate GATB-Tools to review how to start them.

Documentation is here:

*  [Simka](https://github.com/GATB/simka)
*  [DSK](https://github.com/GATB/dsk)
*  [BLOOCOO](https://github.com/GATB/bloocoo)
*  [MindTheGap](https://github.com/GATB/MindTheGap)
*  [Minia](https://github.com/GATB/minia)
*  [Short Read Connector](https://github.com/GATB/short_read_connector)
*  [DiscoSNP++](https://github.com/GATB/DiscoSnp)
*  [TakeABreak](https://github.com/GATB/TakeABreak)
