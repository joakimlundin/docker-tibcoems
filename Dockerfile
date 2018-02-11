# From debian base image
FROM debian:stretch-slim

#Create tibco user
RUN useradd -m tibco

# Install TIBCO EMS
ENV TIBCO_HOME /opt/tibco
WORKDIR ${TIBCO_HOME}/tmp
ADD --chown=tibco:tibco TIB_ems_8.4.0_linux_x86_64.zip .
ADD --chown=tibco:tibco ems_responses.silent .
RUN apt-get update && \
   apt-get install -y unzip procps && \
   apt-get clean && \
   unzip TIB_ems_8.4.0_linux_x86_64.zip && \
   chmod +x TIBCOUniversalInstaller-lnx-x86-64.bin && \
   ${TIBCO_HOME}/tmp/TIBCOUniversalInstaller-lnx-x86-64.bin -silent -V responseFile="ems_responses.silent" && \
   chown tibco:tibco -R ${TIBCO_HOME}

# Add benchmark queue
RUN echo "benchmark prefetch=1000" | tee -a ${TIBCO_HOME}/config-root/tibco/cfgmgmt/ems/data/queues.conf

# Mount data directory
VOLUME ${TIBCO_HOME}/config-root/tibco/cfgmgmt/ems/data/datastore

# Expose standard ports
EXPOSE 7222

#...and go!
USER tibco
CMD ${TIBCO_HOME}/ems/8.4/bin/tibemsd.sh
