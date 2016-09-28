#!/bin/bash

HOST_TO_RECOVER=$1
HOST_TO_RECOVER_DB_CLUSTER=$2
HOST_TO_RECOVER_USER=dbod

PG_CTL=/usr/pgsql-$PG_VERSION_MAJOR/bin/pg_ctl
LOG=/var/lib/pgsql/pgdata/recovery.log

# remote start
echo -e "$(date) - $(basename $0)\n \
    host to recover: host $HOST_TO_RECOVER - user $HOST_TO_RECOVER_USER - data $HOST_TO_RECOVER_DB_CLUSTER \n" \
    >> $LOG

echo "Starting remotely the $HOST_TO_RECOVER" >> $LOG
ssh -t $HOST_TO_RECOVER_USER@$HOST_TO_RECOVER "sudo -iu postgres $PG_CTL -w -D $HOST_TO_RECOVER_DB_CLUSTER start" >> $LOG

exit 0;
