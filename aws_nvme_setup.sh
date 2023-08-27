#!/bin/bash

# set device name
device=/dev/nvme1n1	
mount==/workspace

fs_type=$(df --output=fstype "$device" | tail -n 1)

if [ -n "$fs_type" ]; then
    echo "ERROR: no file system. Check returned $fs_type for device type $device"
	echo "Trying to create XFS on $device ."
	sudo mkfs -t xfs "$device"
	if [ -n "$fs_type" ]; then
		echo "File system $fs_type create on device:$device"
	else 
		echo "Unable to create XFS file sysetm on $device.  Exiting"
		exit 1
    fi
else
    if [ "$fs_type" = "xfs" ]; then
    	echo "File system $fs_type found on device:$device"
		if [ -n "$mount" ]; then
			echo "$fs_type on $device is not mounted.  Mounting"
			sudo mount $device /workspace
			sudo chown ubuntu:ubuntu /workspace
		fi	

    else
		echo "Expected file system type XFS.  Got $fs_type on $device.  Exiting"
        exit 1
fi
echo "$fs_type on $device is present and mounted."
