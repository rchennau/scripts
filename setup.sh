#!/bin/bash
# set -x                                                          # Enable debug mode in bash
echo on

device=/dev/nvme1n1                                             # define the local variable block device
mount_point=/home/ubuntu/app/data                               # define the local variable mount point


## Check if the device exists and is a block device
if [ -b "$device" ]; then
	echo "Device $device exists."
	# fs_type=$(blkid -o value -s TYPE "$device")
	fs_type=$(df --output=fstype "$device" | tail -n 1)
	if [ "$fs_type" == "xfs" ]; then
               echo "Device $device has an XFS file system"
        else
               echo "Device $device does not have an XFS file system"
               echo "Trying to create XFS on $device ."
               sudo mkfs -t xfs "$device"
               if [ "$fs_type" == "xfs" ]; then
                       echo "Device $device XFS created."
               else
                       echo "Unable to create XFS file system on $device.  Exiting"
                       exit 1
               fi
        fi
fi
source /home/ubuntu/scripts/update_route53.sh                                # run the script to update route53 with current IP
