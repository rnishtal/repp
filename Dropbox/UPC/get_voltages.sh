#!/bin/sh
killall cat

taskset -c 0 cat /dev/urandom > /dev/null &
SIBLINGS=`cat /sys/devices/system/cpu/cpu0/topology/thread_siblings_list | sed 's/,/ /'`
for SIBLING in $SIBLINGS
do
	echo userspace | sudo tee /sys/devices/system/cpu/cpu$SIBLING/cpufreq/scaling_governor > /dev/null
done
for FREQUENCY in `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies`
do
	for SIBLING in $SIBLINGS
	do
		echo $FREQUENCY | sudo tee /sys/devices/system/cpu/cpu$SIBLING/cpufreq/scaling_setspeed > /dev/null
	done
	sleep 0.3
	VOLTAGE=`sudo rdmsr -X 0x198 -p 0`
	VOLTAGE=`echo "ibase=16;$VOLTAGE/100000000" | bc`
	VOLTAGE=`echo "$VOLTAGE / 2^13" | bc -l`
	echo "$FREQUENCY $VOLTAGE"
done

killall cat
