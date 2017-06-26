#!/bin/bash

# ========================================================================================
#
# A script to submit a GATB-Tool job to GoDocker and wait for results. 
#
# It takes up to 3 arguments, in the following order: 
#        user token script [timeout]
#
#  where 'user': user name to login to GoDocker. Required.
#        'token': token used for authentication. Required.
#        'script': the script to submit to GoDocker/gatb_tools_machine 
#                  container. Required.
#        'timeout': amount of seconds to wait for results. Optional. Default is 120 sec.
#
# Dependencies:
#  a. python 2.7
#     Should be available on both OSX or Linux
#  b. godocker_cli (https://bitbucket.org/osallou/go-docker-cli/)
#     Should not be installed on OSX and Linux, so: do it!
#  c. bc - An arbitrary precision calculator language 
#     (available on OSX, can be missing on Linux, so use something like: 
#      sudo apt install bc)
#
#  Author: Patrick Durand, Inria
#          June 2017
# ========================================================================================


# ---- Initialize some variables
# GoDocker authentication information
GD_USER=$1
GD_TOKEN=$2
# Script to send to the service
JOB_SCRIPT=$3
# Max time to wait for result. Unit: seconds. Default is 2 minutes.
TIME_OUT=120
if [ "$#" -ge 4 ]; then
  TIME_OUT=$4
fi
# Resources to use on GoDocker exec node
#  4Gb RAM
GD_RAM=4
#  4 cpu
GD_CPU=4
# By default, only 'home' and 'omaha' will be mounted (see Step 2, below)

# server side file to retrieve; MUST match result file created by $JOB_SCRIPT
# script.
JOB_RESULT=gatb_tool_results.tgz

# Container to use: official gatb_tools_machine v1.0.0
GD_CONTAINER=pgdurand56/gatb_tools_machine100

# ---- Step 1: GoDocker authentication
echo "Logging in to go-docker..."
ANSWER=`godlogin -a $GD_TOKEN -l $GD_USER -s https://godocker.genouest.org`
if [ -n "$ANSWER" ]; then
   echo "ERROR: Unable to login to go-docker"
   echo "       $ANSWER"
   exit 1
fi
echo "   OK"

# ---- Step 2: Submit job to GoDocker 
echo "Submitting script '$JOB_SCRIPT'..."
ANSWER=`godjob create -n gatb_tools_machine -d gatb_tools_machine -c $GD_CPU -r $GD_RAM -i $GD_CONTAINER -s $JOB_SCRIPT -v omaha -v home`
if [[ ! $ANSWER == *"Task added"* ]]; then
   echo "ERROR: Unable to login to go-docker"
   echo "       $ANSWER"
   exit 1
fi
echo "   OK"

# ---- Step 3: wait for GoDocker/gatb_tools_machine results 
JOB_ID=`echo $ANSWER | rev | cut -d ' ' -f1 | rev`
echo "Job started with ID: $JOB_ID"
echo " resources requested: $GD_CPU cpu, $GD_RAM Gb RAM"
# progress bar adapted from: http://mywiki.wooledge.org/BashFAQ/044
# progress bar has a fixed number of steps: 30
barlength=30
bar=""
i=0
while ((i <= barlength)); do
	bar+="="
	((i+=1))
done
# we can compute sleep_time from progress bar size and TIME_OUT value
sleep_time=`bc -l <<< "$TIME_OUT/$barlength"`
echo "Waiting for results... ($TIME_OUT sec at max; Refresh rate: $sleep_time sec)"
i=0
STATUS="?"
LCL_STATUS="?"
# ok, now we start a loop to query GoDocker for the gatb_tools_machine results
while ((i <= barlength)); do
	# query GoDocker
	ANSWER=`godjob show --xml $JOB_ID`
	if [[ ! $ANSWER == *"jobs_infos"* ]]; then
	   echo "ERROR: Unable to get status for job: $JOB_ID"
	   echo "       $ANSWER"
	   exit 1
	fi
	# check status
	LCL_STATUS=`cat jobs_infos.xml | grep "primary_status" | cut -d '>' -f 2 | cut -d '<' -f 1`
    rm -f jobs_infos.xml
    ((i+=1))
    # update progress bar
    printf "\r[%-${barlength}s] [$LCL_STATUS]" "${bar:0:i}"
    # wait a little amount of time
    sleep $sleep_time
    # job is done when we got the 'over' status
    if [[ $LCL_STATUS == "over" ]]; then
  	  printf "\r[%-${barlength}s] [$LCL_STATUS]    " "${bar:0:barlength}"
    	STATUS="over"
    	break
    fi
done

echo

# this may happen when we do not receive the results in the given TIME_OUT amount
# of time
if [[ $STATUS == "?" ]]; then
	echo "ERROR: job timed out"
	exit 1
fi

# ---- Step 4: download GoDocker/gatb_tools_machine results 
# Otherwise, we can query GoDocker to get the gatb_tools_machine result file.
echo "Getting gatb_tools_machine result file: $JOB_RESULT ..."
ANSWER=`godfile download $JOB_ID $JOB_RESULT`
if [[ $ANSWER == *"Not Found"* ]]; then
   echo "ERROR: Unable to get gatb_tools_machine result"
   echo "       $ANSWER"
   exit 1
fi
echo "   OK"


# ---- Step 5: we get the running time
echo "Getting running time..."
ANSWER=`godfile download $JOB_ID god.info`
if [[ $ANSWER == *"Not Found"* ]]; then
   echo "warning: Unable to get running time info"
   echo "       $ANSWER"
   # we consider this is not bad, so no 'exit 1'
else
   time_info=`awk '{printf("%s ",$0)} END {print ""}' god.info`
   start_time=`echo $time_info | cut -d' ' -f 1`
   stop_time=`echo $time_info | cut -d' ' -f 2`
   running_time=`bc -l <<< "$stop_time-$start_time"`
   echo "   $running_time seconds"
   rm -f god.info
fi

# ---- Step 6: gatb_tools_machine is running fine.
echo "SUCCESS"
