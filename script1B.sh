#!/bin/bash

urlcheck()
{
	pagetemp=`echo "$1" |  cut -d '/' -f 3`  #$1=$line
	curl -s $1 > /tmp/"$pagetemp".txt
}

Afile=$1

dir_name=~/Desktop/opsysB

if [ ! -f $dir_name ]; then
	mkdir -p $dir_name
else
	break;
fi

> ~/Desktop/opsysB/outfile.txt

while IFS=$'\n' read line; do 
    if [[ ! $line == "#"* ]]; then
	curlstatus=`curl -s -w "%{http_code}\n" "$line" -o /dev/null` #curl each webpage/line
	pagetemp=`echo "$line" |  cut -d '/' -f 3` #keeps only the http://www.url.com/
	if [ $curlstatus == "200" ]; then
		if [ -f  ~/Desktop/opsysB/"$pagetemp".txt ]; then
			curl -s $line > /tmp/"$pagetemp".txt 
			if [ $(cmp -s ~/Desktop/opsysB/"$pagetemp".txt /tmp/"$pagetemp".txt) != "0" ]; then 
				echo $line >> ~/Desktop/opsysB/outfile.txt 
				rm ~/Desktop/opsysB/"$pagetemp".txt  #removes the outdated output 
				mv /tmp/"$pagetemp".txt ~/Desktop/opsysB  #replaces it with the updated	
			fi
		
		else
			echo "$line INIT" 			
			urlcheck "$line" & #passes line as first argument/with & runs in the backround
		fi
	else
		echo "$line FAILED" 
	fi

     fi

done < "$1"

if [ -s ~/Desktop/opsysB/outfile.txt ]; then
	echo "Changed URLs:"
	cat ~/Desktop/opsysB/outfile.txt

fi

rm ~/Desktop/opsysB/outfile.txt
