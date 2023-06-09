#!/bin/bash

exec &> /home/ubuntu/app/stable-diffusion-webui/webui.log	# Redirect stdout and stderr to the log file
# set -x 								# Enable debug mode in bash
echo on

device=/dev/nvme1n1						# define the local variable block device
mount_point=/home/ubuntu/app/stable-diffusion-webui/models	# define the local variable mount point

/home/ubuntu/scripts/update_route53.sh				# run the script to update route53 with current IP

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
		echo "Installing stable-diffusion."
		## Install Stable Diffusion
		cd /home/ubuntu/app
		echo "Cloning stable-diffusion "
		git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
		echo "Mounting output directory at /home/ubuntu/app/stable-diffusion-webui/outputs "
		/home/ubuntu/goofys postwonder-outputs /home/ubuntu/app/stable-diffusion-webui/outputs
		echo "Copying model directory to /home/ubuntu/app/stable-diffusion-webui/models/Stable-diffusion "
		aws s3 cp s3://postwonder-models /home/ubuntu/app/stable-diffusion-webui/models/Stable-diffusion --recursive
		echo "Copying VAE files  to /home/ubuntu/app/stable-diffusion-webui/models/VAE"
		cp /home/ubuntu/app/stable-diffusion-webui/models/Stable-diffusion/vae* /home/ubuntu/app/stable-diffusion-webui/models/VAE
		echo "Copying controlnet files  to /home/ubuntu/app/stable-diffusion-webui/models/Stable-diffusion "
		cp /home/ubuntu/app/stable-diffusion-webui/models/Stable-diffusion/ControlNet-v1-1 /home/ubuntu/app/stable-diffusion-webui/extensions/sd-webui-controlNet/models
		echo "Installing extensions"
		cd /home/ubuntu/app/stable-diffusion-webui/extensions
		git clone https://github.com/Animator-Anon/animator_extension.git
		git clone https://github.com/deforum-art/deforum-for-automatic1111-webui.git
		git clone https://github.com/zero01101/openOutpaint-webUI-extension.git
		git clone https://github.com/fkunn1326/openpose-editor.git
		git clone https://github.com/hnmr293/posex.git
		git clone https://github.com/nonnonstop/sd-webui-3d-open-pose-editor.git
		git clone https://github.com/camenduru/sd-civitai-browser.git
		git clone https://github.com/hnmr293/posex.git
		git clone https://github.com/Mikubill/sd-webui-controlnet.git
		git clone https://github.com/hnmr293/sd-webui-llul.git
		git clone https://github.com/deforum-art/sd-webui-modelscope-text2video.git
		git clone https://github.com/hako-mikan/sd-webui-supermerger.git
		git clone https://github.com/d8ahazard/sd_dreambooth_extension.git
		git clone https://github.com/yownas/shift-attention.git
		git clone https://github.com/AlUlkesh/stable-diffusion-webui-images-browser.git
		git clone https://github.com/Coyote-A/ultimate-upscale-for-automatic1111.git
		git clone https://github.com/zanllp/sd-webui-infinite-image-browsing.git
		echo "Copying various startup files"
		cp /home/ubuntu/scripts/webui-user.sh /home/ubuntu/app/stable-diffusion-webui
		cp /home/ubuntu/scripts/sd-start.sh /home/ubuntu/app/stable-diffusion-webui
		cp /home/ubuntu/scripts/sd-start.sh /home/ubuntu/app/stable-diffusion-webui
		cp /home/ubuntu/scripts/user.css /home/ubuntu/app/stable-diffusion-webui
		cp /home/ubuntu/scripts/styles.csv /home/ubuntu/app/stable-diffusion-webui
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
tmux send-keys -t webui "cd /home/ubuntu/app/stable-diffusion-webui" Enter
# tmux send-keys -t webui "python -m venv venv" Enter
tmux send-keys -t webui "/home/ubuntu/app/stable-diffusion-webui/sd-start.sh | tee -a webui.log" Enter
exit

# sudo apt install python3-venv
# git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
# /home/ubuntu/goofys -o nonempty postwonder-outputs /home/ubuntu/app/stable-diffusion-webui/outputs
#/home/ubuntu/goofys -o nonempty postwonder-models /home/ubuntu/app/stable-diffusion-webui/models/Stable-diffusion
#/home/ubuntu/goofys -o nonempty postwonder-models/ControlNet-v1-1  /home/ubuntu/app/stable-diffusion-webui/extensions/sd-webui-controlnet/models/ControNet-v1-1
# cp /home/ubuntu//app/stable-diffusion-webui/models/Stable-diffusion/vae* /home/ubuntu/app/stable-diffusion-webui/models/VAE
#cp /home/ubuntu/webui-user.sh /home/ubuntu/app/stable-diffusion-webui/
#cp /home/ubuntu/sd-start.sh /home/ubuntu/app/stable-diffusion-webui/
#cd /home/ubuntu/app/stable-diffusion-webui/extensions
#git clone https://github.com/Animator-Anon/animator_extension.git
#git clone https://github.com/deforum-art/deforum-for-automatic1111-webui.git
#git clone https://github.com/zero01101/openOutpaint-webUI-extension.git
#git clone https://github.com/fkunn1326/openpose-editor.git
#git clone https://github.com/hnmr293/posex.git
#git clone https://github.com/nonnonstop/sd-webui-3d-open-pose-editor.git
#git clone https://github.com/camenduru/sd-civitai-browser.git
#git clone https://github.com/hnmr293/posex.git
#git clone https://github.com/Mikubill/sd-webui-controlnet.git
#git clone https://github.com/hnmr293/sd-webui-llul.git
#git clone https://github.com/deforum-art/sd-webui-modelscope-text2video.git
#git clone https://github.com/hako-mikan/sd-webui-supermerger.git
#git clone https://github.com/d8ahazard/sd_dreambooth_extension.git
#git clone https://github.com/yownas/shift-attention.git
#git clone https://github.com/AlUlkesh/stable-diffusion-webui-images-browser.git
#git clone https://github.com/Coyote-A/ultimate-upscale-for-automatic1111.git
#git clone https://github.com/zanllp/sd-webui-infinite-image-browsing.git
#cp /home/ubuntu/scripts/sd-start.sh /home/ubuntu/app/stable-diffusion-webui
#cp /home/ubuntu/scripts/user.css /home/ubuntu/app/stable-diffusion-webui
#cp /home/ubuntu/scripts/styles.csv /home/ubuntu/app/stable-diffusion-webui
#touch /home/ubuntu/app/stable-diffusion-webui/webui.log
#/home/ubuntu/scripts/update_route53.sh
# aws s3 cp s3://postwonder-models/ControlNet-v1-1 /home/ubuntu/app/stable-diffusion-webui/extensions/sd-webui-controlnet/models/ControlNet-v1-1 --recursive
# Create a new session in tmux named webui and start up webui for stable diffusion
#tmux new-session -d -s webui
#tmux send-keys -t webui "cd /home/ubuntu/app/stable-diffusion-webui" Enter
#tmux send-keys -t webui "python -m venv venv" Enter
#tmux send-keys -t webui "/home/ubuntu/app/stable-diffusion-webui/sd-start.sh | tee -a webui.log" Enter
# Attach to the tmux session with the command 
# tmux attach -t webui

# sudo -H -u ubuntu bash -c '/home/ubuntu/app/stable-diffusion-webui/webui.sh --api --listen --no-progressbar-hiding --enable-insecure-extension-access --gradio-auth=Richard:akc2003 --autolaunch --opt-sub-quad-attention --no-hashing --xformers --opt-channelslast --disable-safe-unpickle'
