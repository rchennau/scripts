#!/bin/bash

# set device name
device=/dev/nvme1n1
sd_mount=/workspace
id=$(id -u)

fs_type=$(df --output=fstype "$device" | tail -n 1)
echo "$fs_type"
if [ -z "$fs_type" ]; then
    echo "ERROR: no file system. Check returned $fs_type for device type $device"
    echo "Trying to create XFS on $device ."
    
    # Create XFS file system    
    if sudo mkfs -t xfs "$device"; then
        fs_type="xfs"
        echo "File system $fs_type created on device:$device"
    else 
        echo "Unable to create XFS file system on $device. Exiting"
        exit 1
    fi

else
    echo "File system $fs_type found on device:$device"
fi
if [ "$fs_type" = "xfs" ]; then
	if [ -z "$sd_mount" ]; then
        echo "$fs_type on $device is not mounted. Mounting"
		sudo mkdir $sd_mount
        	if sudo mount $device $sd_mount; then 
            		sudo chown "$id:$id $sd_mount"
            		echo "Mounted $fs_type on $device is mounted at $sd_mount"
		fi 
	fi
else
	# add code to read for answer and continue
	echo "$fs_type on $device is not XFS. Attempt to overwrite?"
	fs_type="xfs"
       	# Create XFS file system    
      	if sudo mkfs -t xfs "$device"; then
               	# fs_type=$(df --output=fstype "$device" | tail -n 1) 
		fs_type="xfs"
               	echo "File system $fs_type created on device:$device"
		sudo mkdir $sd_mount
               	if sudo mount $device $sd_mount; then 
               		sudo chown "$id:$id" "$sd_mount"
               		echo "Mounted $fs_type on $device is mounted at $sd_mount" 
		fi
         else 
                echo "Unable to create XFS file system on $device. Exiting"
                exit 1
	fi
fi
echo "$fs_type on $device is present and mounted."
