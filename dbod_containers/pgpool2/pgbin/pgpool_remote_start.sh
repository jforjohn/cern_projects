#!/bin/bash

HOST_TO_RECOVER=$1
HOST_TO_RECOVER_DB_CLUSTER=$2
HOST_TO_RECOVER_USER=postgres

PG_VERSION=9.4.5
PG_CTL=/usr/local/pgsql/pgsql-$PG_VERSION_MAJOR/bin/pg_ctl
LOG=recovery.log

# remote start
echo -e "$(date) - $(basename $0)\n \
    host to recover: host $HOST_TO_RECOVER - user $HOST_TO_RECOVER_USER - data $HOST_TO_RECOVER_DB_CLUSTER \n" \
    >> $LOG

echo "Starting remotely the $HOST_TO_RECOVER" >> $LOG
ssh -t $HOST_TO_RECOVER_USER@$HOST_TO_RECOVER "$PG_CTL -w -l $HOST_TO_RECOVER_DB_CLUSTER/postgresql.log -D $HOST_TO_RECOVER_DB_CLUSTER start" >> $LOG 2>&1

exit 0;
