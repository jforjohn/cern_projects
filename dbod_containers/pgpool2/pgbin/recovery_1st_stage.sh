#!/bin/bash

# Recovery script for streaming replication.
# This script assumes that DB node 0 is primary, and 1 is standby.

MASTER_DB_CLUSTER=$1
HOST_TO_RECOVER=$2
HOST_TO_RECOVER_DB_CLUSTER=$3
MASTER_PORT=$4
HOST_TO_RECOVER_USER=dbod
#HOST_TO_RECOVER_ARCHIVE=$HOST_TO_RECOVER_DB_CLUSTER/pg_xlog
ARCHIVE=${HOST_TO_RECOVER_DB_CLUSTER/dbs03/dbs02}
HOST_TO_RECOVER_ARCHIVE=${ARCHIVE%\/data}
MASTER_USER_REPL=pgrepl
MASTER_HOST_REPL=127.0.0.1
PG_VERSION_MAJOR=9.4

MODE=m2s
BACKUP_FILE=pgdata2.bak
PG_VERSION_MAJOR=9.4.5
PG_CTL=/usr/local/pgsql/pgsql-$PG_VERSION_MAJOR/bin/pg_ctl
PG_BASEBACKUP=/usr/local/pgsql/pgsql-$PG_VERSION_MAJOR/bin/pg_basebackup

LOG=recovery.log

echo -e "$(date) - $(basename $0)\n \
    master node: user $MASTER_USER_REPL - data $MASTER_DB_CLUSTER - port $MASTER_PORT \n \
    host to recover: host $HOST_TO_RECOVER - user $HOST_TO_RECOVER_USER - data $HOST_TO_RECOVER_DB_CLUSTER \n" \
    >> $LOG

echo "INFO - Start recovering..." >> $LOG
$PG_BASEBACKUP -D $MASTER_DB_CLUSTER/../$BACKUP_FILE -F t -z -x -v -P -U $MASTER_USER_REPL -h $MASTER_HOST_REPL -p $MASTER_PORT>> $LOG
#if [ $MODE = m2s ]; then
#    sed -i 's/\#hot_standby on/hot_standby on/' $BACKUP_FILE/postgresql.conf
#fi

echo "INFO - Transfering the new PGDATA:$HOST_TO_RECOVER_DB_CLUSTER of $HOST_TO_RECOVER" >> $LOG
scp -r $MASTER_DB_CLUSTER/../$BACKUP_FILE $HOST_TO_RECOVER_USER@$HOST_TO_RECOVER:~/ >> $LOG

echo "INFO - Uncompress : Modify Files : Place to PgDataDir" >>$LOG
ssh -t $HOST_TO_RECOVER_USER@$HOST_TO_RECOVER "mv $BACKUP_FILE /tmp; \
    sudo -iu postgres cp -rf $HOST_TO_RECOVER_DB_CLUSTER/data/* $HOST_TO_RECOVER_DB_CLUSTER/data.old; \
    sudo -iu postgres rm -rf $HOST_TO_RECOVER_DB_CLUSTER/data/*; \
    sudo -iu postgres tar xzfp /tmp/$BACKUP_FILE/base.tar.gz -C $HOST_TO_RECOVER_DB_CLUSTER/data; \
    sudo -iu postgres rm -rf /tmp/$BACKUP_FILE; \
    sudo -iu postgres rm -rf $HOST_TO_RECOVER_ARCHIVE/pg_xlog; \
    sudo -iu postgres mv $HOST_TO_RECOVER_DB_CLUSTER/pg_xlog $HOST_TO_RECOVER_ARCHIVE/pg_xlog; \
    sudo -iu postgres ln -s $HOST_TO_RECOVER_ARCHIVE/pg_xlog $HOST_TO_RECOVER_DB_CLUSTER/pg_xlog" \
    >> $LOG

if [ $MODE = m2s ]; then
    echo "INFO - m2s mode setting the instance as a slave" >> $LOG
    ssh -t $HOST_TO_RECOVER_USER@$HOST_TO_RECOVER "sudo -iu postgres /bin/cp -f $HOST_TO_RECOVER_DB_CLUSTER/../repl_files/* $HOST_TO_RECOVER_DB_CLUSTER" >> $LOG
    #sudo -iu postgres sed -i 's/\#hot_standby = on/hot_standby = on/' $HOST_TO_RECOVER_DB_CLUSTER/postgresql.conf
fi

echo "INFO - Deleting backup which was sent to the recovered node" >> $LOG
/bin/rm -rf $MASTER_DB_CLUSTER/../$BACKUP_FILE

echo "INFO - Recovery of $HOST_TO_RECOVER finished" >> $LOG

exit 0;
