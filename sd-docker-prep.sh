#!/bin/bash

exec &> /home/ubuntu/app/stable-diffusion-webui/webui.log	# Redirect stdout and stderr to the log file
set -x 								# Enable debug mode in bash
echo on

device=/dev/nvme1n1						# define the local variable block device
mount_point=/home/ubuntu/app/stable-diffusion-webui/models	# define the local variable mount point
/home/ubuntu/scripts/update_route53.sh				# run the script to update route53 with current IP

## Check if the device exists and is a block device
if [ -b "$device" ]; then
	echo "Device $device exists."
	fs_type=$(blkid -o value -s TYPE "$device")
	if [ "$fs_type" == "xfs" ]; then
		echo "Device $device has an XFS file system"
	else
		echo "Device $device does not have an XFS file system"
		echo "Trying to create XFS on $device ."
		sudo mkfs -t xfs "$device"
		if [ "$fs_type" == "xfs" ]; then
			echo "Device $device XFS created."
		else 
			echo "Unable to create XFS file sysetm on $device.  Exiting"
			exit 1
		fi
	fi
else
	echo "Device $device does not exist or is not a block device."
	exit 2
fi

## Check if the mount point exists and is a directory
if [ -d "$mount_point" ]; then
	echo "Mount point $mount_point exsits."
	sudo chown -R ubuntu:ubuntu /home/ubuntu/app			# Change ownership to ubuntu (user) and ubuntu (group)
else
	echo "Mount point $mount_point does not exist or is not a directory."
	echo "Trying to mount $device on $mount_point as /home/ubuntu/app ."
	if sudo mount -t xfs "$device" "$mount_point"; then
		echo "Mount successful"
		echo "Changing permisions to user ubuntu."
		sudo chown -R ubuntu:ubuntu /home/ubuntu/app
		echo "Copying model directory to /home/ubuntu/app/stable-diffusion-webui/models/Stable-diffusion "
		aws s3 cp s3://postwonder-models /home/ubuntu/app/stable-diffusion-webui/models/Stable-diffusion --recursive
		echo "Copying VAE files  to /home/ubuntu/app/stable-diffusion-webui/models/VAE"
		cp /home/ubuntu/app/stable-diffusion-webui/models/Stable-diffusion/vae* /home/ubuntu/app/stable-diffusion-webui/models/VAE
		echo "Copying controlnet files  to /home/ubuntu/app/stable-diffusion-webui/models/Stable-diffusion "
		cp /home/ubuntu/app/stable-diffusion-webui/models/Stable-diffusion/ControlNet-v1-1 /home/ubuntu/app/stable-diffusion-webui/extensions/sd-webui-controlNet/models
		echo "Installing extensions"
		cd /home/ubuntu/app/stable-diffusion-webui/extensions
		git clone https://github.com/zero01101/openOutpaint-webUI-extension.git
		git clone https://github.com/fkunn1326/openpose-editor.git
		git clone https://github.com/camenduru/sd-civitai-browser.git
		git clone https://github.com/Mikubill/sd-webui-controlnet.git
		git clone https://github.com/hako-mikan/sd-webui-supermerger.git
		git clone https://github.com/zanllp/sd-webui-infinite-image-browsing.git
		echo "Creating log file"
		touch /home/ubuntu/app/stable-diffusion-webui/webui.log
		sudo chown -R ubuntu:ubuntu /home/ubuntu/app/stable-diffusion-webui
		echo "Stable diffusion requires tmalloc for better CPU memory management"
		echo "Reference issue: https://bytemeta.vip/repo/AUTOMATIC1111/stable-diffusion-webui/issues/10117"
		sudo apt-get install libgoogle-perftools4 libtcmalloc-minimal4 -y
	else
		echo "Mount failed."
		exit 3
	fi
fi
# Create a new session in tmux named webui and start up webui for stable diffusion
echo "Start up stable-diffusion with tmux with session name webui"
tmux new-session -d -s webui
# tmux send-keys -t webui "python -m venv venv" Enter
tmux send-keys -t webui "/home/ubuntu/scripts/doc-startup.sh | tee -a webui.log" Enter
/home/ubuntu/scripts/outputs-sync.sh
exit
