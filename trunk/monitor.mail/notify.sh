#!/bin/sh

cd `realpath $0 | xargs dirname`
logdir="log"
logfile="$logdir/notify.log"
date >> $logfile

datestr=`date`
msg="$datestr: '$*' services have some problems!"

subject="[Monitor] services warning"
contact="user1@email.com, user2@email.com"
echo $msg | mail -s "$subject" $contact 
echo "Done!!" >> $logfile
