#!/bin/bash

# set device name
device=/dev/nvme1n1	
output=$(blkid $device)

if [ -n "$output" ]; then
	fs_type=$(df --output=fstype "$device" | tail -n 1)
    # fs_type=$(blkid -s TYPE -o value $device)
    if [ -n "$fs_type"]; then
        echo "ERROR: no file system. Check returned $fs_type for device type $device"
		echo "Trying to create XFS on $device ."
		sudo mkfs -t xfs "$device"
		if [ -n "$fs_type"]; then
			echo "Fil system $fs_type create on device:$device"
		else 
			echo "Unable to create XFS file sysetm on $device.  Exiting"
			exit 1
        fi
    else
        if [ "fs_type" = "xfs" ]; then
			echo "File system $fs_type found on device:$device"
        else
			echo "Expected file system type XFS.  Got $fs_type on $device.  Exiting"
            exit 1
        fi
    fi
fi