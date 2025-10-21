#!/bin/env bash 

tempCPU(){
	ZONE=$(grep -iRl "x86_pkg_temp" /sys/class/thermal/thermal_zone*/type)
	ZONE="${ZONE%/type}/temp"
	TEMP=$(expr $(cat $ZONE) / 1000)

	echo "CPU: $(awk -F': ' '/model name/ {print $2; exit}' /proc/cpuinfo) | TEMP: $TEMP°C"
}

tempCPU


