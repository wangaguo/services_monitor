#!/bin/sh
# 本程式是用來監控特定網址 有錯時會發出警告
# version   1.1
# author    ossf
# copyright bsd
# ---------------------------------------------------
cd `realpath $0 | xargs dirname`

_date=`date "+%Y-%m-%d"`
_time=`date "+%H-%M-%S"`
_dirname=$_date'_'$_time
mkdir -p $_dirname
cd $_dirname
`ls`
#090105 modified 
#使用方法
#請按照 url=$url" 你要監控的網址"
#等於之間不能有空白

#/usr/local/bin/wget -t 1 -O "$t" http://rt.openfoundry.org/Foundry/Home/index.html
#WWW
url="http://www.openfoundry.org/administrator/index.php"

#OpenFoundry
url=$url" http://of.openfoundry.org/projects/1/news"

#RT
url=$url" http://of.openfoundry.org/rt/Ticket/Display.html?id=176"

#SYMPA:"Subscribe, moderator and owner document
url=$url" http://of.openfoundry.org/sympa/help"

#SVN
url=$url" http://svn.openfoundry.org/ossftw"

#清除上一次有錯誤的網址
#if [ -e `ls ../error_*` ] 
#then
#  `rm ../error_*` 
#fi

#loop for parser url
for i in $url
do
	filename=`printf $i | tr  / '|'` 

	/usr/bin/fetch -o "$_time" "$i"
	#如果沒有原始檔案 先以目前的當作比較的對象
	compare=../correct_answer_"$filename"
	if [ -f $compare ]; then
	#echo file exist! 
	else
		cp $_time $compare
	fi

	#利用DIFF correct_answer與抓下來的作比較 不一樣的話輸出至 抓下來的名子.diff 
	#if /usr/bin/diff ../correct_answer "$t" > "$t".diff
	if /usr/bin/diff -u $compare "$_time" > "$_time""$filename".diff
	then
		rm "$_time"  "$_time$filename."diff
	else
		#echo $? 判斷程式執行成功與否
		e=$?
                #print $?
		echo "difference found! $e: $_date/$_time"
		Except=$Except" $i"
	fi
done
echo $Except
if [ -z "$Except" ]
then
	echo 
	exit 0
else
  	echo $Except > ../$_date'_'$_time'_error.txt' 
  	echo $Except > ../tmp.txt
	echo "請查看"$_date"_"$_time"_error.txt中的錯誤訊息" 	
	exit 1
fi
#exit 0
