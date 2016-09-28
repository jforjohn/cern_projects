#!/bin/env bash

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

MODE=m2s

#PG_CTL=/usr/pgsql-$PG_VERSION_MAJOR/bin/pg_ctl
PG_CTL=/usr/local/pgsql/pgsql-$PG_VERSION/bin/pg_ctl

LOG=/var/log/pgpool/failover-recovery.log
FAILED_USER=dbod
NEW_MASTER_USER=dbod

echo -e "$(date) - $(basename $0)\n \
    failed node: id $FAILED_NODE -> $FAILED_HOSTNAME:$FAILED_PORT @ $FAILED_DB_CLUSTER \n \
    new master:  id $NEW_MASTER -> $NEW_MASTER_HOSTNAME:$NEW_MASTER_PORT @ $NEW_MASTER_DB_CLUSTER \n \
    old master: id $OLD_MASTER \n \
    old primary: id $OLD_PRIMARY \n" \
    >> $LOG

#pg_ctl = /usr/local/pgsql/pgsql-$PG_SERVER_VERSION/bin/pg_ctl

if [ -f $HOME/environment.sh ]; then
    echo "INFO - Exporting environment variables \n" >> $LOG
    source $HOME/environment.sh
else
    echo "WARNING - Environment variables not set \n" >> $LOG
fi

echo "Number of hosts in the cluster: $HOSTS_NO" >> $LOG
echo "Recovery of the host which are not running \n" >> $LOG

#if ssh -T dbod@$HOST$i sudo -u postgres $PG_CTL -D $FAILED_DB_CLUSTER status|grep "is running" >/dev/null 2>&1 
if ssh -t $FAILED_USER@$FAILED_HOSTNAME "sudo -i -u postgres $PG_CTL -D $FAILED_DB_CLUSTER status|grep 'is running'" >> $LOG 2>&1
    then
        echo "Database @ $FAILED_HOSTNAME is still running" >> $LOG
        ssh -t $FAILED_USER@$FAILED_HOSTNAME "sudo -i -u postgres $PG_CTL -w -m f -D $FAILED_DB_CLUSTER stop" >> $LOG 2>&1
        sleep 10
        # recovery of the node
        /usr/local/bun/pcp_recovery_node -n $FAILED_NODE -h $HOSTNAME -p $PCP_PORT -U $PCP_USER >> $LOG 2>&1 
    else
        echo "WARNING - $FAILED_HOSTNAME is not running. skipping follow master command." >> $LOG

        if [ $MODE = m2s ]; then
            echo "INFO - m2s mode setting the instance as a slave" >> $LOG
            echo "INFO - Modifying the conf files of the slave which has been promoted\n" >> $LOG
            ssh -t $NEW_MASTER_USER@$NEW_MASTER_HOSTNAME "sudo -iu postgres sed -i 's/hot_standby = on/\#hot_standby = on/' $NEW_MASTER_DB_CLUSTER/postgresql.conf; \
                sudo -iu postgres /bin/cp -f $NEW_MASTER_DB_CLUSTER/recovery.done $NEW_MASTER_DB_CLUSTER/old.recovery.conf; \
                sudo -iu postgres /bin/rm -f $NEW_MASTER_DB_CLUSTER/recovery.done; \
                sudo -iu postgres $PG_CTL -D $NEW_MASTER_DB_CLUSTER reload" \
                >> $LOG
        fi
    fi
exit 0;

