#!/bin/bash
set -x 								# Enable debug mode in bash
# echo on

device=/dev/nvme1n1						# define the local variable block device
mount_point=/home/ubuntu/app/data				# define the local variable mount point


## Check if the device exists and is a block device
#if [ -b "$device" ]; then
#	echo "Device $device exists."
#	fs_type=$(blkid -o value -s TYPE "$device")
#	if [ "$fs_type" == "xfs" ]; then
#		echo "Device $device has an XFS file system"
#	else
#		echo "Device $device does not have an XFS file system"
#		echo "Trying to create XFS on $device ."
#		sudo mkfs -t xfs "$device"
#		if [ "$fs_type" == "xfs" ]; then
#			echo "Device $device XFS created."
#		else
#			echo "Unable to create XFS file system on $device.  Exiting"
#			exit 1
#		fi
#	fi

# /home/ubuntu/scripts/update_route53.sh				# run the script to update route53 with current IP
sudo mount /dev/nvme1n1 /home/ubuntu/app/data
sudo aws s3 cp s3://postwonder-models /home/ubuntu/app/data --recursive
sudo chown -R ubuntu:ubuntu /home/ubuntu/app/data
docker run --gpus all --restart always --name diffusion_webui -d \
    -v /home/ubuntu/app/data/models:/app/models \
    -v /home/ubuntu/app/stable-diffusion-webui/outputs:/app/outputs \
    -v /home/ubuntu/app/stable-diffusion-webui/extensions:/app/extensions \
    -v /home/ubuntu/app/stable-diffusion-webui/configs:/app/configs \
    -v /home/ubuntu/app/stable-diffusion-webui/others:/tmp/others \
    -p 7860:7860 \
   bobzhao1210/diffusion-webui \
   python webui.py --listen --no-download-sd-model --enable-insecure-extension-access --api --xformers --opt-split-attention --no-progressbar-hiding \
   --enable-insecure-extension-access --share --autolaunch --opt-sub-quad-attention --no-hashing --opt-channelslast --disable-safe-unpickle \
   --cors-allow-origins=https://stable.chennault.net:7860 \
