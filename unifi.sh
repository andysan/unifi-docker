#!/bin/bash

set -e

# vars similar to those found in unifi.init
JSVC=/usr/bin/jsvc
PIDFILE=${RUNDIR}/unifi.pid
JVM_OPTS="
  -Dunifi.datadir=${DATADIR}
  -Dunifi.rundir=${RUNDIR}
  -Dunifi.logdir=${LOGDIR}
  -Djava.awt.headless=true
  -Dfile.encoding=UTF-8
  ${JVM_MAX_HEAP_SIZE:+-Xmx${JVM_MAX_HEAP_SIZE}}
  ${JVM_INIT_HEAP_SIZE:+-Xms${JVM_INIT_HEAP_SIZE}}
"

JSVC_OPTS="
  -home ${JAVA_HOME}
  -classpath /usr/share/java/commons-daemon.jar:${BASEDIR}/lib/ace.jar
  -pidfile ${PIDFILE}
  -procname unifi
  -outfile &1 -errfile &2
  ${JVM_OPTS}"

# One issue might be no cron and lograte, causing the log volume to
# become bloated over time! Consider `-keepstdin` and `-errfile &2`
# options for JSVC.
MAINCLASS='com.ubnt.ace.Launcher'

# trap SIGTERM (or SIGINT or SIGHUP) and send `-stop`
stop_unifi()
{
    echo 'Stopping unifi controller service (TERM signal caught).' >&2
    ${JSVC} -nodetach -pidfile ${PIDFILE} -stop ${MAINCLASS} stop
}

rm -f /var/run/unifi/unifi.pid
trap stop_unifi 1 2 15

# keep attached to shell so we can wait on it
echo 'Starting unifi controller service.'
if ! ${JSVC} -nodetach ${JSVC_OPTS} ${MAINCLASS} start; then
    echo "Error: Unexpected error code from daemon: $?" >&2
    exit 2
fi
