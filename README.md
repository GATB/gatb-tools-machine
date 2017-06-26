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

[Jump to wiki](https://github.com/GATB/gatb-tools-machine/wiki/Building-and-testing-the-gatb_tools_machine-Docker-image)

# How to use the image on the command-line?

[Jump to wiki](https://github.com/GATB/gatb-tools-machine/wiki/Using-gatb_tools_machine-on-the-command-line)

# How to use the image on GoDocker?

[Read the Wiki](https://github.com/GATB/gatb-tools-machine/wiki/Using-GoDocker-on-Genouest)

# License

All GATB-Tools and GATB-Core are covered by [![License](http://img.shields.io/:license-affero-blue.svg)](http://www.gnu.org/licenses/agpl-3.0.en.html).
