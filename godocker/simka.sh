#!/bin/bash

#
#  A basic shell script that will be executed within a gatb_tools_machine
#  container to execute a GATB-Tool on GoDocker using its client API. 
#
#  Author: Patrick Durand, Inria
#          June 2017
#

# Data file to process: provided within the gatb_tools_machine container
export DATA_DIR=/opt/simka/example

# Data file to process is located on Omaha-beach
#export DATA_DIR=/omaha-beach/$LOGNAME/gatb-tools-machine/data/simka

# Tool to execute
export GATB_TOOL=simka
# Archive that will contain results; 
#   see also godocker-test-gtm.sh:$JOB_RESULT variable !!!
export RES_FILE=gatb_tool_results.tgz
# Working directory;
#   do not modify, see comment below
export WK_DIR=/tmp

# Run simka using standard entrypoint of gatb_tools_machine Docker
# container: run-tool.sh.
# We let the program $GATB_TOOL working in /tmp in the Docker container
#  (as a reminder, run-tool.sh forces the use of /tmp as the working dir)
/opt/run-tool.sh -c $GATB_TOOL -- -in $DATA_DIR/simka_input.txt -out $WK_DIR/simka_results/ -out-tmp $WK_DIR/simka_temp_output

# ok?
if [ ! $? -eq 0 ]
then
  echo "$GATB_TOOL: FAILED"
  exit 1
fi

# package results into a single file. Indeed, all files located in /tmp
# won't be visible by GoDocker Client API.
cd $WK_DIR
tar -zcf $RES_FILE simka_results/

# only files located in $GODOCKER_PWD can be retrieved
# using GoDocker client API.
mv $RES_FILE $GODOCKER_PWD
