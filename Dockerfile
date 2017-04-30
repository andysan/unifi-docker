FROM ubuntu:xenial

MAINTAINER Andreas Sandberg <andreas@sandberg.pp.se>

COPY unifi.list /etc/apt/sources.list.d
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv 06E85760C0A52C50
RUN apt-get update
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get install -qy --no-install-recommends openjdk-8-jre-headless unifi

ENV BASEDIR=/usr/lib/unifi \
  DATADIR=/var/lib/unifi \
  RUNDIR=/var/run/unifi \
  LOGDIR=/var/log/unifi \
  JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
  JVM_MAX_HEAP_SIZE=512M \
  JVM_INIT_HEAP_SIZE=

RUN ln -s ${BASEDIR}/data ${DATADIR} && \
  ln -s ${BASEDIR}/run ${RUNDIR} && \
  ln -s ${BASEDIR}/logs ${LOGDIR}

VOLUME ["${DATADIR}", "${RUNDIR}", "${LOGDIR}"]

EXPOSE 6789/tcp 8080/tcp 8443/tcp 8880/tcp 8843/tcp 3478/udp

# Uncommenting these allows unifi to run as user nobody but I don't
# know for sure that all features work so leaving commented out for
# now
#RUN chown -R nobody:nogroup /usr/lib/unifi && \
#    chown -R nobody:nogroup /var/lib/unifi && \
#    chown -R nobody:nogroup /var/log/unifi && \
#    chown -R nobody:nogroup /var/run/unifi
#USER nobody

COPY unifi.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/unifi.sh

WORKDIR /var/lib/unifi

ENTRYPOINT ["/usr/local/bin/unifi.sh"]
