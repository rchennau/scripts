#!/bin/bash
models_folder="/workspace"
output_path="/home/ubuntu/comfy/ComfyUI/output"

# cd /workspace/stable-diffusion-webui
# ln -sf ~/scripts/styles.csv .
# ln -sf ~/scripts/webui-user.sh .

## S3 storag is faster however it it more expensive than Google Drive
#~/goofys postwonder-outputs ~/stable-diffusion-webui/outputs

## Choose your mounting option. Storage cost on Google Drive per gigabyte is cheaper than S3 but requires developer api access.  Plus factor in AWS transfer cost out.
if [ ! -d "$output_path" ]; then
	echo "Folder '$output_path' does not exist.  Let's try creating it."
	mkdir "$output_path"
	echo "Folder '$output_path' directory created successfully."
	rclone mount gdrive:outputs /home/ubuntu/ComfyUI/output --vfs-cache-mode writes --progress --transfers=10 --checkers=8 --drive-chunk-size 64M --no-checksum  --daemon
else
	echo "Folder '$models_folder' already exist."
	# Check if the directory is empty
		if [ "$(ls -A $directory)" ]; then
  		echo "The directory '$directory' is not empty. Exiting"
	else
  		echo "The directory '$directory' is empty. Mounting gdrive"
		rclone mount gdrive:outputs /home/ubuntu/ComfyUI/output --vfs-cache-mode writes --progress --transfers=10 --checkers=8 --drive-chunk-size 64M --no-checksum  --daemon
	fi
fi

if [ ! -d "$models_folder" ]; then
	echo "Folder '$models_folder' does not exist.  Let's try mounting it."
	mount /dev/mapper/vg.01-lv_ephemeral /workspace
	# mkdir -p "$models_folder" # -p creates parent directory if needed
	# echo "Folder '$models_folder' created successfully."
	echo "Folder '$models_folder' mounted successfully."
	aws s3 cp s3://postwonder-models /workspace/models --recursive
else 
	echo "Folder '$models_folder' already exist."
	mount /dev/mapper/vg.01-lv_ephemeral /workspace
	aws s3 cp s3://postwonder-models /workspace/models --recursive
fi
