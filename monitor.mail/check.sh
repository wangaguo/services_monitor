#!/bin/sh
# 本程式是用來監控特定網址 有錯時會發出警告
# version   1.1
# author    ossf
# copyright bsd
# ---------------------------------------------------
cd `realpath $0 | xargs dirname`

_date=`date "+%Y-%m-%d"`
_time=`date "+%H-%M-%S"`

#使用方法
#請按照 url=$url" 你要監控的網址"
#等於之間不能有空白

#WWW
url="http://www.openfoundry.org/"

#whoswho
url=$url" http://whoswho.openfoundry.org/"

logdir="log"
tmp="$logdir/latest_check.txt"
`cp /dev/null $tmp`

#loop for parser url
for i in $url
do
        status=`./check.pl $i`
        echo $status
	if [ "$status" -ne 1 ]
        then
		echo "difference found! $e: $_date/$_time"
		Except="$Except $i"
		echo $i >> $tmp 
	fi
done

if [ -z "$Except" ]
then
	echo 
	exit 0
else
  	echo `cp $tmp $logdir/$_date'_'$_time'_error.txt'`
	echo "請查看"$_date"_"$_time"_error.txt中的錯誤訊息" 	
	exit 1
fi
