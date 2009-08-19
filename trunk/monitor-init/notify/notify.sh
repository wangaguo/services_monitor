#!/bin/sh

#./PCHomeSMS/PCHomeSMS.sh 0968767061 'rt has some problem!'

cd `realpath $0 | xargs dirname`


logfile=notify.log
date >> $logfile

datestr=`date`
msg="$datestr: services have some problems!"

# put your settings in "local_settings"
nums="0909123456"
pchome_name=""
pchome_pass=""
pchome_pay_pass=""
. local_settings

./notify.pl "$pchome_name" "$pchome_pass" "$pchome_pay_pass" $nums "$msg" 

date >> $logfile


