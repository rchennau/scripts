#!/bin/bash
# set -x                                                          # Enable debug mode in bash
# echo on

device_name=/dev/nvme1n1                                             # define the local variable block device
#device_name=$(lsblk -o NAME | grep nvme1n1 | sed -n 1p) 		# define the local variable block device
mount_point=/home/ubuntu/app/data                               # define the local variable mount point

printf "Checking to see if device exists.\n"
## Check if the device exists and is a block device
if [ -b "$device_name" ]; then
	printf "Device $device_name exists.\n"
	# fs_type=$(blkid -o value -s TYPE "$devic_namee")
	#fs_type=$(df --output=fstype "$device_name" | tail -n 1)
	fs_type=$(lsblk -f "$device_name" | awk '/^\/nvme1n1/{print $2}') 
        printf "fs_type =  $fs_type .\n"
	if [ "$fs_type" == "xfs" ]; then
               printf "Device $device_name has an XFS file system\n"
	       exit 1
        else
	       printf "Device $device_name does not have an XFS file system\n"
               printf "Trying to create XFS on $device_name .\n"
               sudo mkfs -t xfs "$device_name"
	       fs_type=$(lsblk -f "$device_name" | awk '/^\/nvme1n1/{print $2}') 
               printf "fs_type =  $fs_type .\n"
               if [ "$fs_type" == "xfs" ]; then
                    printf "Device $device_name XFS created."
		    exit 2
               else
                    printf "Unable to create XFS file system on $device_name.  Exiting\n"
		    # exit 3
               fi
        fi
fi
source /home/ubuntu/scripts/update_route53.sh                                # run the script to update route53 with current IP
sudo mount $device_name /home/ubuntu/app/data
sudo fallocate -l 20G /home/ubuntu/app/data/swapfile
sudo chmod 600 /home/ubuntu/app/data/swapfile
sudo mkswap /home/ubuntu/app/data/swapfile
sudo swapon /home/ubuntu/app/data/swapfile
source /home/ubuntu/scripts/doc-stable.sh
