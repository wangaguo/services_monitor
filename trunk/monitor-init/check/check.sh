#!/bin/sh

cd `realpath $0 | xargs dirname`

d=`date "+%Y-%m-%d"`
t=`date "+%H-%M-%S"`

mkdir -p $d
cd $d

#/usr/local/bin/wget -t 1 -O "$t" http://rt.openfoundry.org/Foundry/Home/index.html
/usr/bin/fetch -o "$t" 'http://of.openfoundry.org/projects/1/news'

if /usr/bin/diff ../correct_answer "$t" > "$t".diff
then
	rm "$t"  "$t."diff
else
	e=$?
	echo "difference found! $e: $d/$t"
	exit $e 
fi

