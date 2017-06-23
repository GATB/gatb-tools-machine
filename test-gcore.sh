#!/usr/bin/env bash
#
# A script to test GATB-Core HDF5 utils.
#
# Not to be used as is: it is added into the Docker image within /opt; see Dockerfile.
#
# Author: Patrick G. Durand, Inria, June 2017

cd bin

echo "Testing dbginfo..."
./dbginfo -in ../test/db/celegans_reads.h5 
var=$?
if [ ! $var -eq 0 ]
then
  echo "dbginfo: FAILED"
  exit 1
fi
echo "  PASSED" 

echo "Testing h5dump..."
./h5dump -H ../test/db/celegans_reads.h5
var=$?
if [ ! $var -eq 0 ]
then
  echo "h5dump: FAILED"
  exit 1
fi
echo "  PASSED" 

echo "Testing dbgh5..."
./dbgh5 -in ../test/db/reads3.fa.gz
var=$?
if [ ! $var -eq 0 ]
then
  echo "dbgh5: FAILED"
  exit 1
fi
echo "  PASSED" 

