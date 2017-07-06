#!/bin/bash

#########################################################################################
#
# Companion file to be used with Dockerfile.alpine-compiler
#
# This is THE master script that start to compile all GATB-Tools listed
# hereafter. 
#
#  It works using two main steps:
#    1. getting official source and Linux binary archives from Github mirrors
#    2. running a Dockerfile.alpine-compiler container to compile GATB-Tools.
#
# Author: Patrick G. Durand, Inria, July 2017
#
#########################################################################################

# GATB-Tools for which we have to prepare an Alpine-base binary.
declare -a tool_list
tool_list[0]="simka;simka;simka;1.4.0;example;simple_test.sh"
tool_list[1]="dsk;dsk;dsk;2.2.0;test;simple_test.sh"
tool_list[2]="bloocoo;Bloocoo;Bloocoo;1.0.7;test;simple_test.sh"
tool_list[3]="DiscoSnp;DiscoSNP.;DiscoSNP++;2.2.10;test;simple_test.sh"
tool_list[4]="minia;minia;minia;2.0.7;none;none" 
tool_list[5]="TakeABreak;TakeABreak;TakeABreak;1.1.2;tests;simple_test.sh"

# error codes
CURL_SRC_ERROR=7
CURL_BIN_ERROR=8

# set a dedicated time format
TIMEFORMAT='      Time - real:%3lR | user:%3lU | sys:%3lS'

# working directory: will be created
WKDIR=$PWD/wkdir/
mkdir -p "${WKDIR}"

# Start the job
cd "${WKDIR}"
for tool in "${tool_list[@]}"; do
  # get gatb-tool fields: names and release nb.
  arr=(${tool//;/ })
  FNAME=${arr[0]}-v${arr[3]}
  echo "##  Getting ${FNAME} official archives"
  # Prepare the curl command to get source package
  TOOLTGZ=${arr[1]}-v${arr[3]}-Source.tar.gz
  GIT_URL=https://github.com/GATB/${arr[0]}/releases/download
  TOOLURL=${GIT_URL}/v${arr[3]}/${TOOLTGZ}
  echo "    getting source from: ${TOOLURL} ..."
  time curl -ksL ${TOOLURL} | tar xz
  if [ ! $? -eq 0 ]; then
      echo "    FAILED"
      exit $CURL_SRC_ERROR
  fi
  echo "      OK"
  # Prepare the curl command to get std Linux binary bundle
  TOOLTGZ=${arr[1]}-v${arr[3]}-bin-Linux.tar.gz
  GIT_URL=https://github.com/GATB/${arr[0]}/releases/download
  TOOLURL=${GIT_URL}/v${arr[3]}/${TOOLTGZ}
  echo "    getting std Linux binary from: ${TOOLURL} ..."
  time curl -ksL ${TOOLURL} | tar xz
  if [ ! $? -eq 0 ]; then
      echo "    FAILED"
      exit $CURL_BIN_ERROR
  fi
  echo "      OK"
  # run docker container to compile code and make Alpine Binary Bundle
  time docker run --rm -i -t -v "${WKDIR}":/tmp gatb_tools_alpine_compiler $tool
done

# Then: transfer to Inria Forge storage; only donc on Jenkins CI platform
# scp *-bin-Alpine.tar.gz $FORGE_LOGIN@$FORGE_SERVER:/home/groups/gatb-tools/htdocs/ci-inria
