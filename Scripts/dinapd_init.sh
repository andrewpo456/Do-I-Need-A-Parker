#!/bin/bash
#
# Daemon Name: dinapd
#
# chkconfig - 58 74
# description: Do I need a Parker (weather daemon)
# requires: mysqld

# Source function library
. /etc/init.d/functions

# DINAP config file (should be with the script)
. dinap_config

prog=dinapd
lockfile=/var/lock/subsys/$prog
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" #The current working directory of the init script

# Perform root check
if [[ $EUID -ne 0 ]]; then
  echo "You must be root to run this script ... exiting."
  #exit 1
fi

start() {
  # Make some checks for requirements before continuing
  [ -x ../$prog ] || exit 5      #The Daemon executable should be within the directory above

  # Start our daemon
  echo -n $"Starting $prog: "
  
  #Create my process and create the PID file
  daemon --pidfile /var/run/${proc}.pid ../$prog
  RETVAL=$?
  echo
  
  # If all is well touch the lock file - Which ensures only one script is running at a time
  [ $RETVAL -eq 0 ] && touch $lockfile   
  return $RETVAL
}

stop() {
  echo -n $"Shutting down $prog: "
  
  #Kill the process and remove the prog file  
  killproc $prog
  RETVAL=$?
  echo

  # If all is well remove the lockfile
  [ $RETVAL -eq 0 ] && rm -f $lockfile
  return $RETVAL
}

# See how we were called.
case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    status $prog
    ;;
  restart)
    stop
    start
    ;;
  *)
    echo $"Usage: $0 {start|stop|status|restart}"
    exit 2
esac

