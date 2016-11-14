#!/bin/bash

# failover.sh
# wrapper script to mysqlrpladmin
# user:password pair, must have administrative privileges.

# user:password pair, must have REPLICATION SLAVE privileges.
repluser={{ repl_user }}:{{ repl_password_txt }}
user={{ failover_user }}:{{ failover_password_txt }}
never_master=None

LOG=/var/log/maxscale/failover.log
ARGS=$(getopt -o '' --long 'initiator:,event:,nodelist:,masterlist:,slavelist:' -- "$@")

echo -e "$(date) - $(basename $0)\n" >> $LOG

eval set -- "$ARGS"
echo $ARGS >> $LOG

while true; do
    case "$1" in
        --event)
            shift;
            event=$1
            shift;
        ;;
        --initiator)
            shift;
            initiator=$1
            shift;
        ;;
        --nodelist)
            shift;
            nodelist=$1
            shift;
        ;;
        --masterlist)
            shift;
            masterlist=$1
            shift;
        ;;
        --slavelist)
            shift;
            slavelist=$1
            shift;
        ;;
        --)
            shift;
            break;
        ;;
    esac
done

# find the candidates
for i in $(echo $nodelist | sed -e 's/,/\n/g')
do
  if [[ "$i" =~ "$never_master" ]]
  then
     echo "INFO - node $i in the never master list option $never_master" >> $LOG
  else
     if [[ "$i" =~ "$initiator" ]]
     then
        echo "INFO - node $i is the server which initiated the event $event" >> $LOG
     else
        candidates="$candidates,${user}@${i}"
        echo "INFO - Event: $event candidates: $candidates" >> $LOG
        masterHost=${i%:*}
        masterPort=${i#*:}
        echo "Event: $event Master: $masterHost Port: $masterPort" >> $LOG
     fi
  fi
  if [[ "$i" =~ "$initiator" ]]
  then
     echo "INFO - node $i is the server which initiated the event $initiator" >> $LOG
  else
     slaves="$slaves,${user}@${i}"
     echo "INFO - Event: $event slaves: $slaves" >> LOG
  fi
done

failovercmd="/usr/bin/mysqlrpladmin --rpl-user=$repluser --slaves=${slaves#?} --candidates=${candidates#?} --log=$LOG --force failover"
echo $event: $failovercmd >> $LOG
eval $failovercmd >> $LOG 2>&1

mysqlcmd="mysql -h $masterHost -P $masterPort -u ${user%:*} -p ${user#*:} -e 'SET GLOBAL read_only=OFF;'"
echo $event: $mysqlcmd >> $LOG
eval $mysqlcmd >> $LOG 2>&1

echo -e "INFO - failover finished\n" >> $LOG
exit 0;
