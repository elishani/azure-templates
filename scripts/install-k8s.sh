#!/bin/bash

apt update

myIp=`ip addr  show eth0 | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1`
preIp=`echo $myIp | cut -d'.' -f1-3`
postIp=`echo $myIp | cut -d'.' -f4`
lastUp=`expr $postIp + 1`
lastDown=`expr $postIp - 1`
upIp="$preIp.$lastUp"
downIp="$preIp.$lastDown"
i=5
while true; do
	ping -c1 $upIp
	if [ $? = 0  ]; then
		station2=$upIp
		break
	fi
	ping -c1 $downIp
	if [ $? = 0  ]; then
                station2=$downIp
                break
	fi
	i=`expr $i - 1`
	[ $i = 0 ] && break
done
if [ -z $station2 ]; then
        echo "No ping to other machine"
fi
