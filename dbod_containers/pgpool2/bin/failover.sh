#!/bin/sh

# Failover command for streaming replication.
# This script assumes that DB node 0 is primary, and 1 is standby.
#
# If standby goes down, do nothing. If primary goes down, create a
# trigger file so that standby takes over primary node.
#
# Arguments: $1: failed node id. $2: new master hostname. $3: path to
# trigger file.

failed_node=$1
new_master=$2
trigger_file=$3
PGDATA=$4               # %R

# Do nothing if standby goes down.
if [ $failed_node = 1 ]; then
        exit 0;
    fi

    # Create the trigger file.
    /usr/bin/ssh -T $new_master /bin/touch $PG_DATA/$trigger_file
    #/usr/bin/docker exec $new_master /bin/touch $PG_DATA/$trigger_file

    exit 0;
: '
FALLING_NODE=$1         # %d
OLDPRIMARY_NODE=$2      # %P
NEW_PRIMARY=$3          # %H
PGDATA=$4               # %R


if [ $FALLING_NODE = $OLDPRIMARY_NODE ]; then
    if [ $UID -eq 0 ]
    then
        su postgres -c "ssh -T postgres@$NEW_PRIMARY touch $PGDATA/trigger"
    else
        ssh -T postgres@$NEW_PRIMARY touch $PGDATA/trigger
    fi
    exit 0;
fi;
exit 0;
'
