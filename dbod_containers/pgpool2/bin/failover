#!/usr/bin/env bash

# Failover command for streaming replication.
# This script assumes that DB node 0 is primary, and 1 is standby.
#
# If standby goes down, do nothing. If primary goes down, create a
# trigger file so that standby takes over primary node.
#
# Arguments: $1: failed node id. $2: new master hostname. $3: path to
# trigger file.

FAILED_NODE=${1}          # %d
FAILED_HOSTNAME=${2}      # %h
FAILED_PORT=${3}          # %p
FAILED_DB_CLUSTER=${4}    # %D
NEW_MASTER=${5}           # %m
NEW_MASTER_HOSTNAME=${6}  # %H
NEW_MASTER_PORT=${7}      # %r
NEW_MASTER_DB_CLUSTER=${8} # %R
OLD_MASTER=${9}           # %M
OLD_PRIMARY=${10}         # %P

PG_CTL=/usr/pgsql-PG_VERSION_MAJOR/bin/pg_ctl
TRIGGER_FILE=${11}

LOG=/var/log/pgpool/failover-recovery.log
NEW_MASTER_USER=dbod

echo -e "$(date) - $(basename $0)\n \
    failed node: id $FAILED_NODE -> $FAILED_HOSTNAME:$FAILED_PORT @ $FAILED_DB_CLUSTER \n \
    new master:  id $NEW_MASTER -> $NEW_MASTER_HOSTNAME:$NEW_MASTER_PORT @ $NEW_MASTER_DB_CLUSTER \n \
    old master: id $OLD_MASTER \n \
    old primary: id $OLD_PRIMARY \n \
    trigger file: $TRIGGER_FILE \n" \
    >> $LOG

if [ -f $HOME/environment.sh ]; then
    echo "INFO - exporting environment variables \n" >> $LOG
    source $HOME/environment.sh
else
    echo "WARNING - Environment variables not set \n" >> $LOG
fi

# Do nothing if standby goes down.
if [[ $NEW_MASTER = $OLD_MASTER ]] || [[ $NEW_MASTER = $OLD_PRIMARY ]]; then
    echo "WARNING - Failed node is a slave. Restart it and attach it to Pgpool" >> $LOG
    exit 0;
elif [[ $FAILED_NODE = $OLD_MASTER ]] || [[ $NEW_MASTER != $OLD_PRIMARY ]]; then
    echo "WARNING - Master failover" >> $LOG
    echo "WARNING - Create the trigger file \n" >> $LOG
    #$PG_CTL -h $NEW_MASTER_HOSTNAME -p $NEW_MASTER_PORT -D $NEW_MASTER_DB_CLUSTER -w promote >> $log
    /usr/bin/ssh -t $NEW_MASTER_USER@$NEW_MASTER_HOSTNAME "sudo -iu postgres /bin/touch $NEW_MASTER_DB_CLUSTER/$TRIGGER_FILE" >> $LOG
    #/usr/bin/docker exec $NEW_MASTER /bin/touch $PGDATA/$TRIGGER_FILE
else
    echo "ERROR - Waas!? Something weird happened... \n" >> $LOG
fi
exit 0;
