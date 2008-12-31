#!/bin/sh

cd /root/monitor

logfile=monitor.log

echo >> $logfile
date >> $logfile

if ./check/check.sh >> $logfile 2>&1
then
	echo "ok" >> $logfile
else
	echo "check failed!" >> $logfile

	if [ -n "`find lastnotifytime -ctime -245m`" ]
	then
	        echo "We have notified recently." >> $logfile
	else
	        echo "Going to notify." >> $logfile
		./notify/notify.sh
		touch lastnotifytime
	fi

fi
