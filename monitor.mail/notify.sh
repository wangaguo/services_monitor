#!/bin/sh

cd `realpath $0 | xargs dirname`

logfile=log/notify.log
date >> $logfile

datestr=`date`
msg="$datestr: "$1"services have some problems!"

echo $msg | mail -s alert! "email@domain.com" 
date >> $logfile


