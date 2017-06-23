#!/usr/bin/env bash
#
# A script to be used within a Docker container: it aims at starting a GATB-Tool 
# program given some parameters.
#
# Use: ./run-tool.sh -c <command> -- <arguments>
#
#        <command>: MUST BE one of (case-sensitive): 
#                   - simka, simka-visu, 
#                   - bloocoo, metabloocoo,
#                   - dsk, dsk2ascii
#                   - MindTheGap
#                   - minia
#                   - rconnector (Short Read Connector)
#                   - discosnp
#                   - takeabreak
#                   - h5dump, dbgh5, dbginfo
#                   - test: start a test of all above-mentioned tools
#                   - version: list tools and their releases
#      <arguments>: remaining arguments passed in after <command> are passed
#                   to the GATB-Tool program.
#                   Please refer to these programs to review their expected arguments.
#
# Author: Patrick G. Durand, Inria, June 2017
# ========================================================================================
# Section: utility function declarations
# --------
# FUNCTION: display help message
function help(){
  printf "\n$0: a tool to invoke a GATB-Tool within a Docker container.\n\n"
  printf "usage: $0 -c <command> -- [arguments]\n\n"
  exit 1
}

# ========================================================================================
# Section: Main

# Prepare arguments for processing
while getopts hc: opt
do
  case "$opt" in
    c)  COMMAND="$OPTARG";;
    h)  help;;
    \?) help;;
  esac
done
shift `expr $OPTIND - 1`

# remaining arguments, if any, are supposed to be the [file ...] part of the command-line
ALL_ARGS=$@

#execute command
case "$COMMAND" in
  version)
    echo ""
    echo "> This Docker image contains the following GATB-Tools:"
    echo ""
    echo "  GATB-Core HDF5 utils: $GCORE_VERSION.  Documentation: http://gatb-core.gforge.inria.fr/doc/api/dbgh5_page.html"
    echo "  Simka:              : $SIMKA_VERSION.  Documentation: https://github.com/GATB/simka"
    echo "  DSK                 : $DSK_VERSION.  Documentation: https://github.com/GATB/dsk"
    echo "  BLOOCOO             : $BLOOCOO_VERSION.  Documentation: https://github.com/GATB/bloocoo"
    echo "  MindTheGap          : $MIND_VERSION.  Documentation: https://github.com/GATB/MindTheGap"
    echo "  Minia               : $MINIA_VERSION.  Documentation: https://github.com/GATB/minia"
    echo "  Short Read Connector: $SRC_VERSION.  Documentation: https://github.com/GATB/short_read_connector"
    echo "  DiscoSNP++          : $DSNP_VERSION. Documentation: https://github.com/GATB/DiscoSnp"
    echo "  TakeAbreak          : $TABK_VERSION.  Documentation: https://github.com/GATB/TakeABreak"
    echo ""
    ;;
  test)
    echo "###################################"
    echo "# Testing GATB-Core HDF5 Utility..."
    echo "###################################"
    cd /opt/gatb-core 
    ./test-gcore.sh
    echo "####################"
    echo "# Testing Simka..."
    echo "####################"
    cd /opt/simka/example 
    ./simple_test.sh
    echo "####################"
    echo "# Testing DSK..."
    echo "####################"
    cd /opt/dsk/test 
    ./simple_test.sh
    echo "####################"
    echo "# Testing BLOCOO..."
    echo "####################"
    cd /opt/bloocoo/test 
    ./simple_test.sh
    echo "#######################"
    echo "# Testing MINDTHEGAP..."
    echo "#######################"
    cd /opt/MindTheGap/test 
    ./simple_test.sh
    echo "##################################"
    echo "# Testing SHORT READ CONNECTOR..."
    echo "#################################"
    cd /opt/rconnector/test 
    ./simple_test.sh
    echo "#####################"
    echo "# Testing DISCOSNP..."
    echo "#####################"
    cd /opt/discosnp/test 
    ./simple_test.sh
    echo "#######################"
    echo "# Testing TAKEABREAK..."
    echo "#######################"
    cd /opt/TakeABreak/tests 
    ./simple_test.sh
    ;;
  h5dump)
    /opt/gatb-core/bin/h5dump $ALL_ARGS
    ;;
  dbgh5)
    /opt/gatb-core/bin/dbgh5 $ALL_ARGS
    ;;
  dbginfo)
    /opt/gatb-core/bin/dbginfo $ALL_ARGS
    ;;
  simka)
    /opt/simka/bin/simka $ALL_ARGS
    ;;
  simka-visu)
    python2.7 /opt/simka/scripts/visualization/run-visualization.py $ALL_ARGS
    ;;
  dsk)
    /opt/dsk/bin/dsk $ALL_ARGS
    ;;
  dsk2ascii)
    /opt/dsk/bin/dsk2ascii $ALL_ARGS
    ;;
  bloocoo)
    /opt/bloocoo/bin/Bloocoo $ALL_ARGS
    ;;
  metabloocoo)
    /opt/bloocoo/bin/metaBloocoo $ALL_ARGS
    ;;
  MindTheGap)
    /opt/MindTheGap/bin/MindTheGap $ALL_ARGS
    ;;
  minia)
    /opt/minia/bin/minia $ALL_ARGS
    ;;
  rconnector)
    /opt/rconnector/short_read_connector.sh $ALL_ARGS
    ;;
  discosnp)
    /opt/discosnp/run_discoSnp++.sh $ALL_ARGS
    ;;
  takeabreak)
    /opt/TakeABreak/bin/TakeABreak $ALL_ARGS
    ;;
esac

exit 0

