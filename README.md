# *GATB-TOOLS* and *Docker*

This document explains how you can setup and use *GATB-Tools* within a Docker container.

## What are GATB-Tools?

[GATB-Tools](https://gatb.inria.fr/software/) are softwares built upon the [GATB-Core Library](https://github.com/GATB/gatb-core/wiki). 

As of June 2017, this projet includes within a single Docker image :

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

[Jump to wiki](https://github.com/GATB/gatb-tools-machine/wiki/Building-and-testing-the-gatb_tools_machine-Docker-image)

# How to use the image on the command-line?

[Jump to wiki](https://github.com/GATB/gatb-tools-machine/wiki/Using-gatb_tools_machine-on-the-command-line)

# How to use the image on GoDocker?

[Read the Wiki](https://github.com/GATB/gatb-tools-machine/wiki/Using-GoDocker-on-Genouest)

# Files

| **File name** | **Description** |
|---------------|-----------------|
| Dockerfile    | Production ready material: the main Docker file to use to create the GATB-Tools machine. This is the one cited in above sections. |
| Dockerfile.alpine | An alternative way to build the GATB-Tools machine, using Alpine Linux instead of Debian. Experimental material: use with caution. Read more [here](https://github.com/GATB/gatb-tools-machine/wiki/Optimising-Docker-Container-size-using-Alpine-Linux). |
| Dockerfile.alpine-compiler | Production ready material: an Alpine based c/c++ compiler to prepare Alpine native binaries of GATB-Tools. Read more [here](https://github.com/GATB/gatb-tools-machine/wiki/Optimising-Docker-Container-size-using-Alpine-Linux). |
| Dokcerfile.alpine2 | Production ready material: the Dockerfile to use to create a compact GATB-Tools machine. Read more [here](https://github.com/GATB/gatb-tools-machine/wiki/Optimising-Docker-Container-size-using-Alpine-Linux). |
| build.sh | Companion file of  Dockerfile.alpine-compiler |
| make_all.sh | Companion file of Dockerfile.alpine-compiler. Actually, it is the one to use to generate GATB-Tool Alpine binaries: 'make_all.sh' script invokes 'Dockerfile.alpine-compiler' container. |
| run-tool.sh | Starter script of Docker containers (i.e. ENTRYPOINT) |
| test-gcore.sh | Companion file of Dockerfile |
| data | Directory with test material for all GATB-Tools |
| godocker | Directory with material illustrating how to use GATB-Tools-Machine on the [GoDocker platform](http://www.genouest.org/godocker/). |

# License

All GATB-Tools and GATB-Core are covered by [![License](http://img.shields.io/:license-affero-blue.svg)](http://www.gnu.org/licenses/agpl-3.0.en.html).
