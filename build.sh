#!/bin/bash

#########################################################################################
#
# Companion file to be used with Dockerfile.alpine-compiler
#
# This script is embedded within the container: it is responsible for compiling
# GATB-Tools.
#
#########################################################################################
#
# A shell script to compile GATB-Tools using Alpine system: c/c++ libs and compiler.
#
# Use: build.sh "name1;name2;name3;version;test-path;test-script"
#      (see below for a description of this single string-based argument)
#
# It works as follows:
#  a. get a GATB-Tool Source bundle from Github/GATB
#  b. compile the source within an Alpine Docker Container
#  c. get the standard GATB-Tool Linux binary bundle from Github/GATB
#  d. update 'bin' with Alpine binaries
#  e. rename the binary bundle to 'Alpine'
#  f. run tool test-suite
#  g. re-archive the 'new' Alpine Binary bundle
#
# Declaration of a GATB-Tool description is done using a single string-based argument
# within double quotes. This argument is formated as:
#
#  "name1;name2;name3;version;test-path;test-script"
#
#  where:
#   [0]:name1:       GATB-Tool github project name 
#   [1]:name2:       GATB-Tool name of the tarball
#   [2]:name3:       GATB-Tool name after extracting tarball
#   [3]:version:     GATB-Tool version to retrieve and compile (without prefix 'v')
#   [4]:test-path:   name of subfolder containing Tool's test suite. Pass 'none' if
#                    no test available.
#   [5]:test-script: name of test script to launch. Again, pass 'none' if not test.
#
#   Caution: - ';' is the field separator
#            - do not add space chars in between fields and ';'
#            - do not forget to enclose string within " (otherwise cmd-line won't work)
#
#   Example with DiscoSnp (for which name evolved strongly over time):
#    https://github.com/GATB/DiscoSnp/releases/download/v2.2.10/DiscoSNP.-v2.2.10-Source.tar.gz
#    ........................<-[0]-->....................<[3]->.<--[1]-->......................
#
#    Then, after tar xz on "DiscoSNP.-v2.2.10-Source.tar.gz", we have:
#    that folder created: DiscoSNP++-v2.2.10-Source
#                         <--[2]--->...............
#
# Author: Patrick G. Durand, Inria, July 2017
#
#########################################################################################

# Here are some ready-to-use descriptions to compile these GATB-Tools:
#
# "simka;simka;simka;1.4.0;example;simple_test.sh"                        ... OK on July 4th, 2017
# "dsk;dsk;dsk;2.2.0;test;simple_test.sh"                                 ... OK on July 4th, 2017
# "bloocoo;Bloocoo;Bloocoo;1.0.7;test;simple_test.sh"                     ... OK on July 4th, 2017
# "MindTheGap;MindTheGap;MindTheGap;2.0.1;test;simple_test.sh"            ... KO on July 4th, 2017
#                                                                                TEST FAILED: need to fix diff cmd in test scripts
# "DiscoSnp;DiscoSNP.;DiscoSNP++;2.2.10;test;simple_test.sh"              ... OK on July 4th, 2017
# "minia;minia;minia;2.0.7;none;none"                                     ... KO on July 4th, 2017
#                                                                                MAKE FAILED: need to fix cmake cmd
#                                                                         ... OK on July 5th, 2017
# "TakeABreak;TakeABreak;TakeABreak;1.1.2;tests;simple_test.sh"           ... OK on July 4th, 2017 
#
# This tool cannot be handled for now:
# "short_read_connector;rconnector;rconnector;1.1.0;test;simple_test.sh"  ... KO on July 4th, 2017
#                                                                                TEST FAILED: need dsk binary. No easy way to handle tool dependency...
#
# Simple use:
#   
#   docker run --rm -i -t -v $PWD/wkdir/:/tmp gatb_tools_alpine_compiler "minia;minia;minia;2.0.7;none;none"
#
#   where '$PWD/wkdir' has to be created first: this is the place where Alpine Binary bundles
#   are created on YOUR local directory.
#
#

# ##  DECLARATIONS  #####################################################################

# 'Make' command can use these many cores
CORES=4
# This is the working directory INSIDE the container. You can map it 
# outside the container using docker -v argument
WK_DIR=/tmp
# get cmd-line argument in an appropriate variable: the GATB-Tool to process
GATB_TOOL_DESCRIPTION=$1
# Sample string format (only for help message)
WKDIR_HELP="/path/to/wkdir"
CMD_HELP="docker run --rm -it -v $WKDIR_HELP:/tmp gatb_tools_compiler"
DESC_HELP="simka;simka;simka;1.4.0;example;./simple_test.sh"
RES_HELP="docker execution results will be located in $WKDIR_HELP: an Alpine binary bundle."
# In case of error, this script will return a dedicated code !=0
NB_ARGS_ERROR=1
ARGS_ERROR=2
CMAKE_ERROR=3
MAKE_ERROR=4
TEST_ERROR_CODE=5
CD_SRC_DIR_ERROR=6
CURL_SRC_ERROR=7
CURL_BIN_ERROR=8
LINUX_BIN_ERROR=9
TEST_DIR_ERROR=10
TEST_SCRIPT_ERROR=11
CP1_BIN_ERROR=12
CP2_BIN_ERROR=13
# Figure out whether or not this script get GATB-Tool official archives
# (source and binary) from Github. Set to zero if using Docker container
# on INRIA-CI platform: access to the web is not allowed.
DO_CURL=0
# set a dedicated time format
TIMEFORMAT='      Time - real:%3lR | user:%3lU | sys:%3lS'

# ##  MAIN  #############################################################################

# Check argument
if [ "$#" -ne 1 ]; then
    echo "ERROR: missing GATB-Tool description string."
    echo "  sample: $CMD_HELP \"$DESC_HELP\""
    echo "  $RES_HELP"
    exit $NB_ARGS_ERROR
fi

nb_strings=$(grep -o ";" <<< "$1" | wc -l)
if [ "$nb_strings" -ne 5 ]; then
    echo "ERROR: bad format for description string"
    echo "  sample: $CMD_HELP \"$DESC_HELP\""
    echo "  $RES_HELP"
    exit $ARGS_ERROR
fi

# == STEP 1: get source code if requested. This step is optional
# since using this script within Docker containers on Inria CI
# platform prevents any remote connection to the Internet.
# Be sure we are in the appropriate directory
cd ${WK_DIR}
# get gatb-tool fields: names and release nb.
arr=(${GATB_TOOL_DESCRIPTION//;/ })
FNAME=${arr[0]}-v${arr[3]}
echo "##  Making: ${FNAME}"
# Prepare the curl command
if [ "$DO_CURL" -eq "1" ]; then
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
fi

# == STEP 2: compile source code
# Prepare the cmake/make call
TOOL_BASE_NAME=${arr[2]}-v${arr[3]}
cd ${TOOL_BASE_NAME}-Source
if [ ! $? -eq 0 ]; then
    echo "    cd ${TOOL_BASE_NAME}-Source: FAILED"
    exit $CD_SRC_DIR_ERROR
fi
mkdir -p build
cd build
echo "    running CMake in: $PWD ..."
if [ ${arr[0]} == "minia" ]; then
  # As of July 2017, do not understand why classical cmake with 
  # debug=off and -DCMAKE_BUILD_TYPE=Release does not work with minia tool
  time cmake .. > ${WK_DIR}/${FNAME}-CMake.log 2>&1 
else
  # No LTO:
  time cmake -Ddebug=OFF -DCMAKE_BUILD_TYPE=Release .. > ${WK_DIR}/${FNAME}-CMake.log 2>&1 
  # With LTO:
  # time cmake -Ddebug=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS_RELEASE="-O3 -DNDEBUG -flto" -DCMAKE_AR="/usr/bin/gcc-ar" -DCMAKE_CXX_ARCHIVE_FINISH="" ..
fi
if [ ! $? -eq 0 ]; then
    echo "    CMake: FAILED."
    echo "     See: ${WK_DIR}/${FNAME}-CMake.log"
    exit $CMAKE_ERROR
fi 
echo "      OK"

echo "    running make ..."
time make -j${CORES} > ${WK_DIR}/${FNAME}-make.log 2>&1 
if [ ! $? -eq 0 ]; then
    echo "    make: FAILED"
    echo "     See: ${WK_DIR}/${FNAME}-make.log"
    exit $MAKE_ERROR
fi
echo "      OK"
cd ${WK_DIR}

# == STEP 3: get Linux binary bundle if requested. This step is optional
# since using this script within Docker containers on Inria CI
# platform prevents any remote connection to the Internet.
# Prepare the curl command to get std Linux binary bundle
if [ "$DO_CURL" -eq "1" ]; then
  TOOLTGZ=${arr[1]}-v${arr[3]}-bin-Linux.tar.gz
  GIT_URL=https://github.com/GATB/${arr[0]}/releases/download
  TOOLURL=${GIT_URL}/v${arr[3]}/${TOOLTGZ}
  echo "    getting std Linux binary from: ${TOOLURL} ..."
  curl -ksL ${TOOLURL} | tar xz
  if [ ! $? -eq 0 ]; then
      echo "    FAILED"
      exit $CURL_BIN_ERROR
  fi
  echo "      OK"
fi

# == STEP 4: prepare Alpine binary bundle
# update that archive: replace bin programs with Alpine ones
echo "    preparing Alpine binary bundle ..."
if [ ! -d ${TOOL_BASE_NAME}-bin-Linux ]; then
    echo "    FAILED: unable to locate: ${TOOL_BASE_NAME}-bin-Linux"
    exit $LINUX_BIN_ERROR
fi
# we simply rename the Linux archive and replace appropriate files
mv ${TOOL_BASE_NAME}-bin-Linux ${TOOL_BASE_NAME}-bin-Alpine
cd ${TOOL_BASE_NAME}-bin-Alpine
rm -rf bin ; mkdir bin ; cd bin
# these are the Alpine binaries for the Gatb-Tool under processing
cp ../../${TOOL_BASE_NAME}-Source/build/bin/* .
if [ ! $? -eq 0 ]; then
    echo "    FAILED: unable to copy ${arr[0]} Alpine binaries"
    exit $CP1_BIN_ERROR
fi
# some tools also require to have h5dump (e.g. DSK)
# Fix for minia: h5dump is NOT in a Release directory !!!
if [ ${arr[0]} == "minia" ]; then
  cp ../../${TOOL_BASE_NAME}-Source/build/ext/gatb-core/bin/h5dump .
else
  cp ../../${TOOL_BASE_NAME}-Source/build/ext/gatb-core/bin/Release/h5dump .
fi
# some tools also require to have dbgh5 (e.g. Discosnp)
if [ ${arr[0]} == "DiscoSnp" ]; then
  cp ../../${TOOL_BASE_NAME}-Source/build/ext/gatb-core/bin/Release/dbgh5 .
fi
if [ ! $? -eq 0 ]; then
    echo "    FAILED: unable to copy ${arr[0]} dbgh5 binary"
    exit $CP2_BIN_ERROR
fi
echo "      OK"
# we run tool's test suite if available 
if [ ! ${arr[4]} == "none" ]; then
  # during previous, we are in 'bin' directory. Tests, if any, are
  # located at the same level than 'bin'
  cd ..
  echo "    testing ${TOOL_BASE_NAME} Alpine binaries ..."
  if [ ! -d ${arr[4]} ]; then
      echo "    FAILED: unable to locate test directory: ${arr[4]}"
      exit TEST_DIR_ERROR
  fi
  cd ${arr[4]}
  if [ ! -f ${arr[5]} ]; then
      echo "    FAILED: unable to locate test script: ${arr[5]}"
      exit TEST_SCRIPT_ERROR
  fi
  # fix for some GATB-Tools: test script was not package with +x 
  # permission
  chmod +x ${arr[5]}
  # add a fix (e.g. problem met with MindTheGap): set +x on ALL scripts
  chmod +x *.sh
  # add a fix (e.g. problem met with DiscoSnp): set +x on tests scripts 
  # located outside test directory
  chmod +x ../*.sh  > /dev/null 2>&1
  # add another fix for DiscoSnp: test scripts outside test directory !!!
  chmod +x ../scripts/*.sh > /dev/null 2>&1
  sh ${arr[5]} > ${WK_DIR}/${FNAME}-test.log 2>&1 
  if [ ! $? -eq 0 ]; then
      echo "    test: FAILED"
      echo "     See: ${WK_DIR}/${FNAME}-test.log"
      exit $TEST_ERROR_CODE
  fi
  echo "      OK"
fi

# == STEP 5: package Alpine binary bundle
echo "    archiving Alpine bundle in: ${TAR_BAL} ..."
TAR_BAL=${TOOL_BASE_NAME}-bin-Alpine.tar.gz
cd ${WK_DIR}
# remove any 'old' tarball
[ -e ${TAR_BAL} ] && rm -f ${TAR_BAL}
# remove all testing stuff to reduce package size
cd ${TOOL_BASE_NAME}-bin-Alpine
rm -rf test* data example > /dev/null 2>&1
cd ..
# package the Alpine bundle for gatb-tool ${arr[2]}
tar -cf ${TOOL_BASE_NAME}-bin-Alpine.tar ${TOOL_BASE_NAME}-bin-Alpine
time gzip ${TOOL_BASE_NAME}-bin-Alpine.tar
# made some additional cleanup
rm -rf ${TOOL_BASE_NAME}-bin-Alpine ${TOOL_BASE_NAME}-Source
echo "      OK"

exit 0
