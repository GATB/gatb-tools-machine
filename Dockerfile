#########################################################################################
#
#  Docker file for GATB-Tools project.
#
#  It prepares a Docker container to run various GATB-Tools jobs: 
#
#    Simka               : https://github.com/GATB/simka
#    DSK                 : https://github.com/GATB/dsk
#    BLOOCOO             : https://github.com/GATB/bloocoo
#    MindTheGap          : https://github.com/GATB/MindTheGap
#    MINIA               : https://github.com/GATB/minia
#    SHORT READ CONNECTOR: https://github.com/GATB/short_read_connector
#    DISCOSNP            : https://github.com/GATB/DiscoSnp
#    TAKEABREAK          : https://github.com/GATB/TakeABreak
#    
#########################################################################################
#
# == Docker build command:
#
#    docker build -f Dockerfile -t gatb_tools_machine .
#
# == Docker test command:
#
#    docker run --rm -i -t gatb_tools_machine -c test
#
#    -> you should see a all GATB-Tools tests with some provided data.
#
# == Running a Tool job:
#
#    docker run --rm -i -t gatb_tools_machine -c <command> -- <arguments>
#
#    where:
#        <command>: see ./run-tool.sh
#      <arguments>: see ./run-tool.sh
#
# == Sample Simka job with provided data:
#    
#    To illustrate the use of this GATB-Tools Docker Image, let's take the example of
#    running SIMKA tool.
#
#    docker run --rm -i -t -v $PWD:/tmp gatb_tools_machine -c simka -- -in /opt/simka/example/simka_input.txt -out /tmp/simka_results/ -out-tmp /tmp/simka_temp_output
#
#    -> you should have results in $PWD/simka_results directory when Simka job is done.
#
#    This command-line line explained:
#
#    docker run                                 [1]
#       --rm                                    [2]
#       -i -t                                   [3]
#       -v $PWD:/tmp                            [4]
#       gatb_tools_machine                      [5] 
#       -c simka                                [6]
#       --                                      [7]
#       -in /opt/simka/example/simka_input.txt  [8]
#       -out /tmp/simka_results/                [9]
#       -out-tmp /tmp/simka_temp_output         [10]
#
#       [1]-[5]: Docker arguments
#       [6]-[7]: simka container's invoker program
#       [8]-[10]: 'bin/simka' arguments
#
#       [1]: start Docker container
#       [2]: destroy container when Docker finishes
#            (it does NOT delete the 'gatb_tools_machine' image)
#       [3]: start an interactive job 
#            (for instance, you'll see messages on stdout, if any)
#       [4]: mount a volume. This is required to get the results from Simka.
#            Here, we say that current local directory will be viewed as '/tmp'
#            from the inside of the container. 
#       [5]: tell Docker which image to start: the 'gatb_tools_machine' of course.
#       [6]: ask to start the simka program. See companion file 'run-tool.sh' for
#            more information.
#       [7]: '--' is required to separate arguments [6] from the rest of the
#            command line
#       [8]: the data file to process with simka. Here we use a data file
#            provided with the simka software to test it.
#       [9]: tells simka where to put results. Of course, simka will write 
#            within /tmp directory inside the container. However, since we
#            have directive [4], data writing is actually done in $PWD, i.e.
#            a local directory.
#       [10]: tells simka where to put temporary files. 
#
# == Additional notes
# 
#   Root access inside the container:
#
#     - if running: docker exec -it gatb_tools_machine bash
#
#     - if not yet running: docker run --rm -i -t gatb_tools_machine bash
#
#########################################################################################

# GATB-Tools binaries available on Github (see below) are built using a 
# Debian 8 (jessie) based system on Inria Jenkins CI platform
FROM debian:jessie

# who to blame?
MAINTAINER Patrick Durand patrick.durand@inria.fr

# ###
#     Package installation and configuration
#
#     1. We need 'curl' for all tools to get them from Github.
#     2. GATB-Tools dependencies are as follows: 
#        a. Simka     : python-2.7 and R
#        b. Bloocoo   : none
#        c. DSK       : none
#        d. MindTheGap: bsdmainutils (MindTheGap test script requires the command
#                       'column' which is included in bsdmainutils Debian package)
#        e. Minia     : none
#        f. RConnector: none
#        g. DiscoSnp  : python-2.7
#        h. TakeABreak: none
#
RUN apt-get update && apt-get -y dist-upgrade \
    && apt-get install -y --no-install-recommends bsdmainutils curl python2.7 r-base \
    && apt-get clean \
    && cd /usr/bin && ln -s python2.7 python

# ###
#     SIMKA installation: get the binary release from Github mirror.
#
#     We always use the latest official binary release available.
ENV SIMKA_VERSION=1.4.0
RUN cd /opt \
    && export SIMKA_TGZ=simka-v${SIMKA_VERSION}-bin-Linux.tar.gz \
    && export GIT_URL=https://github.com/GATB/simka/releases/download \
    && export SIMKA_URL=${GIT_URL}/v${SIMKA_VERSION}/${SIMKA_TGZ} \
    && curl -ksL ${SIMKA_URL} | tar xz \
    && rm -f ${SIMKA_TGZ} \
    && mv simka-v${SIMKA_VERSION}-bin-Linux simka \
    && cd simka/bin \
    && chmod +x simka* \
    && cd ../example \
    && chmod +x *.sh \
    && ./simple_test.sh

# ###
#     DSK installation: get the binary release from Github mirror.
#
#     We always use the latest official binary release available.
ENV DSK_VERSION=2.2.0
RUN cd /opt \
    && export DSK_TGZ=dsk-v${DSK_VERSION}-bin-Linux.tar.gz \
    && export GIT_URL=https://github.com/GATB/dsk/releases/download \
    && export DSK_URL=${GIT_URL}/v${DSK_VERSION}/${DSK_TGZ} \
    && curl -ksL ${DSK_URL} | tar xz \
    && rm -f ${DSK_TGZ} \
    && mv dsk-v${DSK_VERSION}-bin-Linux dsk \
    && cd dsk/bin \
    && chmod +x * \
    && cd ../test \
    && chmod +x *.sh \
    && ./simple_test.sh

# ###
#     BLOOCOO installation: get the binary release from Github mirror.
#
#     We always use the latest official binary release available.
ENV BLOOCOO_VERSION=1.0.7
RUN cd /opt \
    && export BLOOCOO_TGZ=Bloocoo-v${BLOOCOO_VERSION}-bin-Linux.tar.gz \
    && export GIT_URL=https://github.com/GATB/bloocoo/releases/download \
    && export BLOOCOO_URL=${GIT_URL}/v${BLOOCOO_VERSION}/${BLOOCOO_TGZ} \
    && curl -ksL ${BLOOCOO_URL} | tar xz \
    && rm -f ${BLOOCOO_TGZ} \
    && mv Bloocoo-v${BLOOCOO_VERSION}-bin-Linux bloocoo \
    && cd bloocoo/bin \
    && chmod +x * \
    && cd ../test \
    && chmod +x *.sh \
    && ./simple_test.sh

# ###
#     MINDTHEGAP installation: get the binary release from Github mirror.
#
#     We always use the latest official binary release available.
ENV MIND_VERSION=2.0.1
RUN cd /opt \
    && export MIND_TGZ=MindTheGap-v${MIND_VERSION}-bin-Linux.tar.gz \
    && export GIT_URL=https://github.com/GATB/MindTheGap/releases/download \
    && export MIND_URL=${GIT_URL}/v${MIND_VERSION}/${MIND_TGZ} \
    && curl -ksL ${MIND_URL} | tar xz \
    && rm -f ${MIND_TGZ} \
    && mv MindTheGap-v${MIND_VERSION}-bin-Linux MindTheGap \
    && cd MindTheGap/bin \
    && chmod +x * \
    && cd ../test \
    && chmod +x *.sh \
    && ./simple_test.sh

# ###
#     GATB-Core installation: get the binary release from Github mirror.
#     Note: we only keep HDF5 utility tools: dbgh5, dbginfo, h5dump
#
#     We always use the latest official binary release available.
ENV GCORE_VERSION=1.3.0
RUN cd /opt \
    && export GCORE_TGZ=gatb-core-${GCORE_VERSION}-bin-Linux.tar.gz \
    && export GIT_URL=https://github.com/GATB/gatb-core/releases/download \
    && export GCORE_URL=${GIT_URL}/v${GCORE_VERSION}/${GCORE_TGZ} \
    && curl -ksL ${GCORE_URL} | tar xz \
    && rm -f ${GCORE_TGZ} \
    && mv gatb-core-${GCORE_VERSION}-bin-Linux gatb-core \
    && cd gatb-core \
    && rm -rf examples include lib test/gatb-core-cppunit \
    && cd bin \
    && chmod +x * \
    && mv gatb-h5dump h5dump

COPY test-gcore.sh /opt/gatb-core
RUN cd /opt/gatb-core && ./test-gcore.sh  && rm -f /opt/gatb-core/bin/reads3.fa.h5

# ###
#     MINIA installation: get the binary release from Github mirror.
#
#     We always use the latest official binary release available.
ENV MINIA_VERSION=2.0.7
RUN cd /opt \
    && export MINIA_TGZ=minia-v${MINIA_VERSION}-bin-Linux.tar.gz \
    && export GIT_URL=https://github.com/GATB/minia/releases/download \
    && export MINIA_URL=${GIT_URL}/v${MINIA_VERSION}/${MINIA_TGZ} \
    && curl -ksL ${MINIA_URL} | tar xz \
    && rm -f ${MINIA_TGZ} \
    && mv minia-v${MINIA_VERSION}-bin-Linux minia \
    && cd minia/bin \
    && chmod +x * 

# ###
#     SHORT-READ-CONNECTOR installation: get the binary release from Github mirror.
#
#     We always use the latest official binary release available.
ENV SRC_VERSION=1.1.0
RUN cd /opt \
    && export SRC_TGZ=rconnector-v${SRC_VERSION}-bin-Linux.tar.gz \
    && export GIT_URL=https://github.com/GATB/short_read_connector/releases/download \
    && export SRC_URL=${GIT_URL}/v${SRC_VERSION}/${SRC_TGZ} \
    && curl -ksL ${SRC_URL} | tar xz \
    && rm -f ${SRC_TGZ} \
    && mv rconnector-v${SRC_VERSION}-bin-Linux rconnector \
    && cd rconnector \
    && chmod +x *.sh \
    && cd bin \
    && chmod +x * \
    && cd ../test \
    && chmod +x *.sh \
    && ./simple_test.sh

# ###
#     DISCO-SNP installation: get the binary release from Github mirror.
#
#     We always use the latest official binary release available.
ENV DSNP_VERSION=2.2.10
RUN cd /opt \
    && export DSNP_TGZ=DiscoSNP.-v${DSNP_VERSION}-bin-Linux.tar.gz \
    && export GIT_URL=https://github.com/GATB/DiscoSnp/releases/download \
    && export DSNP_URL=${GIT_URL}/v${DSNP_VERSION}/${DSNP_TGZ} \
    && curl -ksL ${DSNP_URL} | tar xz \
    && rm -f ${DSNP_TGZ} \
    && mv DiscoSNP++-v${DSNP_VERSION}-bin-Linux discosnp \
    && cd discosnp \
    && chmod +x *.sh \
    && cd bin \
    && chmod +x * \
    && cd ../scripts \
    && chmod +x *.sh \
    && cd ../test \
    && chmod +x *.sh \
    && ./simple_test.sh

# ###
#     TAKE-A-BREAK installation: get the binary release from Github mirror.
#
#     We always use the latest official binary release available.
ENV TABK_VERSION=1.1.2
RUN cd /opt \
    && export TABK_TGZ=TakeABreak-v${TABK_VERSION}-bin-Linux.tar.gz \
    && export GIT_URL=https://github.com/GATB/TakeABreak/releases/download \
    && export TABK_URL=${GIT_URL}/v${TABK_VERSION}/${TABK_TGZ} \
    && curl -ksL ${TABK_URL} | tar xz \
    && rm -f ${TABK_TGZ} \
    && mv TakeABreak-v${TABK_VERSION}-bin-Linux TakeABreak \
    && cd TakeABreak/bin \
    && chmod +x * \
    && cd ../tests \
    && chmod +x *.sh \
    && ./simple_test.sh

# ###
#     BCALM installation: get the binary release from Github mirror.
#
#     We always use the latest official binary release available.
#
#     COMMENTED OUT: tests failed (i.e. run-tiny.sh)!
#
#ENV BCALM_VERSION=2.1.0-beta1
#RUN cd /opt \
#    && export BCALM_TGZ=bcalm-binaries-v${BCALM_VERSION}-Linux.tar.gz \
#    && export GIT_URL=https://github.com/GATB/bcalm/releases/download \
#    && export BCALM_URL=${GIT_URL}/v${BCALM_VERSION}/${BCALM_TGZ} \
#    && curl -ksL ${BCALM_URL} | tar xz \
#    && rm -f ${BCALM_TGZ} \
#    && mv bcalm-binaries-v${BCALM_VERSION}-Linux bcalm \
#    && cd bcalm/bin \
#    && chmod +x * \
#    && cd ../example \
#    && chmod +x *.sh \
#    && ./run-tiny.sh

# ###
#     Starter script.
#
COPY run-tool.sh /opt

# Fix: ensure script has exec permission
RUN chmod +x /opt/run-tool.sh

# ###
#     Start a GATB-Tool. See "run-tool.sh" header for more information.
#
ENTRYPOINT ["/opt/run-tool.sh"]


