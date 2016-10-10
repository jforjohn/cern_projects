#!/bin/bash

# Recovery script for streaming replication.
# This script assumes that DB node 0 is primary, and 1 is standby.

MASTER_DB_CLUSTER=$1
HOST_TO_RECOVER=$2
HOST_TO_RECOVER_DB_CLUSTER=$3
MASTER_PORT=$4

#HOST_TO_RECOVER_ARCHIVE=$HOST_TO_RECOVER_DB_CLUSTER/pg_xlog
ARCHIVE=${HOST_TO_RECOVER_DB_CLUSTER/dbs03/dbs02}
HOST_TO_RECOVER_ARCHIVE=${ARCHIVE%\/data}
HOST_TO_RECOVER_USER=postgres
MASTER_USER_REPL=pgrepl
MASTER_HOST_REPL=127.0.0.1

MODE=m2s
PG_VERSION=9.4.5
PG_CTL=/usr/local/pgsql/pgsql-$PG_VERSION/bin/pg_ctl
PG_BASEBACKUP=/usr/local/pgsql/pgsql-$PG_VERSION/bin/pg_basebackup

TIMESTAMP=`date +'%s'`
BACKUP_FILE=pgdata2-$TIMESTAMP.bak 
OLD_DATA_DIR=data-$TIMESTAMP
LOG=$MASTER_DB_CLUSTER/recovery.log
KEYTAB_FILE=/etc/dbod/pgkrb5.keytab

echo -e "$(date) - $(basename $0)\n \
    master node: user $MASTER_USER_REPL - data $MASTER_DB_CLUSTER - port $MASTER_PORT \n \
    host to recover: host $HOST_TO_RECOVER - user $HOST_TO_RECOVER_USER - data $HOST_TO_RECOVER_DB_CLUSTER - \n \
    archive $HOST_TO_RECOVER_ARCHIVE \n" \
    >> $LOG

if [ -z $MASTER_DB_CLUSTER ] || [ -z $MASTER_DB_CLUSTER ] || [ -z $HOST_TO_RECOVER_DB_CLUSTER ] || [ -z $MASTER_PORT ]; then
    echo -e "One or more of the $(basename $0) script are not set. Check $LOG. Exiting..." >> $LOG
    exit 0;
fi

echo "INFO - Start recovering..." >> $LOG
$PG_BASEBACKUP -D $MASTER_DB_CLUSTER/../$BACKUP_FILE -F t -z -x -v -P -U $MASTER_USER_REPL -h $MASTER_HOST_REPL -p $MASTER_PORT>> $LOG 2>&1
#if [ $MODE = m2s ]; then
#    sed -i 's/\#hot_standby on/hot_standby on/' $BACKUP_FILE/postgresql.conf
#fi
echo "INFO - Initialize Kerbros ticket" >> $LOG
kinit -kt $KEYTAB_FILE $HOST_TO_RECOVER_USER

echo "INFO - Transfering the new PGDATA:$HOST_TO_RECOVER_DB_CLUSTER of $HOST_TO_RECOVER" >> $LOG
scp -r $MASTER_DB_CLUSTER/../$BACKUP_FILE $HOST_TO_RECOVER_USER@$HOST_TO_RECOVER:$HOST_TO_RECOVER_DB_CLUSTER/.. >> $LOG 2>&1

echo "INFO - Uncompress : Modify Files : Place to PgDataDir" >>$LOG
ssh -t $HOST_TO_RECOVER_USER@$HOST_TO_RECOVER "mv $HOST_TO_RECOVER_DB_CLUSTER $HOST_TO_RECOVER_DB_CLUSTER/../$OLD_DATA_DIR; \
    mkdir -p $HOST_TO_RECOVER_DB_CLUSTER; \
    chmod 700 $HOST_TO_RECOVER_DB_CLUSTER; \
    tar xzfp $HOST_TO_RECOVER_DB_CLUSTER/../$BACKUP_FILE/base.tar.gz -C $HOST_TO_RECOVER_DB_CLUSTER; \
    mv $HOST_TO_RECOVER_ARCHIVE/pg_xlog $HOST_TO_RECOVER_ARCHIVE/pg_xlog-$TIMESTAMP; \
    mv $HOST_TO_RECOVER_DB_CLUSTER/pg_xlog $HOST_TO_RECOVER_ARCHIVE/pg_xlog; \
    ln -s $HOST_TO_RECOVER_ARCHIVE/pg_xlog $HOST_TO_RECOVER_DB_CLUSTER/pg_xlog; \
    mv $HOST_TO_RECOVER_DB_CLUSTER/recovery.done $HOST_TO_RECOVER_DB_CLUSTER/recovery.done-$TIMESTAMP 2> /dev/null; \
    mv $HOST_TO_RECOVER_DB_CLUSTER/recovery.log $HOST_TO_RECOVER_DB_CLUSTER/recovery-$TIMESTAMP.log 2> /dev/null; \
    touch $HOST_TO_RECOVER_DB_CLUSTER/recovery.log; \
    touch $HOST_TO_RECOVER_DB_CLUSTER/$MODE" \ 
    >> $LOG 2>&1

#/bin/mkdir -p $HOST_TO_RECOVER_DB_CLUSTER/../$OLD_DATA_DIR; 
#/bin/cp -rf $HOST_TO_RECOVER_DB_CLUSTER/* $HOST_TO_RECOVER_DB_CLUSTER/../data.old; 
#rm -r $HOST_TO_RECOVER_DB_CLUSTER; 

if [ $MODE = m2s ]; then
    echo "INFO - m2s mode setting the instance as a slave" >> $LOG 2>&1
    ssh -t $HOST_TO_RECOVER_USER@$HOST_TO_RECOVER "cp -f $HOST_TO_RECOVER_DB_CLUSTER/../repl_files/{pg_hba.conf,postgresql.conf,recovery.conf} $HOST_TO_RECOVER_DB_CLUSTER" >> $LOG 2>&1
    #sed -i 's/\#hot_standby = on/hot_standby = on/' $HOST_TO_RECOVER_DB_CLUSTER/postgresql.conf
fi

#echo "INFO - Deleting backup which was sent to the recovered node" >> $LOG
#/bin/rm -r $MASTER_DB_CLUSTER/../$BACKUP_FILE

echo -e "INFO - Recovery of $HOST_TO_RECOVER finished \n" >> $LOG

exit 0;
