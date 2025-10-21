#!/bin/env bash 

tempCPU(){
	ZONE=$(grep -iRl "x86_pkg_temp" /sys/class/thermal/thermal_zone*/type)
	ZONE="${ZONE%/type}/temp"
	TEMP=$(expr $(cat $ZONE) / 1000)

	echo "$(awk -F': ' '/model name/ {print $2; exit}' /proc/cpuinfo) | TEMP: $TEMP°C"
}

tempDisk(){
mapfile -t disk_array < <(cat /sys/class/hwmon/hwmon*/device/model)
i=1

for DISK in "${disk_array[@]}"; do
	DPATH=$(grep -iRl "$DISK" /sys/class/hwmon/hwmon*/device/model)
	DPATH="${DPATH/device\/model/temp1_input}"

	DTEMP=$(expr $(cat $DPATH) / 1000)

	echo "$i. $DISK | Temp: $DTEMP"

	i=$(($i+1))
done
}

echo "CPU:"
echo "$(tempCPU)"
echo "--------------------------------------------------------------"
echo "Disks:"
echo "$(tempDisk)"
