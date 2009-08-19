#!/bin/sh

cd `realpath $0 | xargs dirname`
logdir="log"
logfile="$logdir/monitor.log"
tmp="$logdir/latest_check.txt"

mkdir -p $logdir

echo >> $logfile
date >> $logfile

if ./check.sh >> $logfile 2>&1
then
        echo "ok" >> $logfile
	echo "check ok."
else
        echo "check failed!" >> $logfile
	echo "check failed!"

        if [ -n "`find lastnotifytime -ctime -1m`" ]
        then
                echo "We have notified recently." >> $logfile
        else
                echo "Going to notify." >> $logfile
                errorurl=`cat $tmp`
                ./notify.sh `cat $tmp` 
                touch lastnotifytime
        fi
fi
echo "Done."
