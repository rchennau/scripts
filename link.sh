#!/bin/bash
models_folder="/workspace/models"
output_path="/home/ubuntu/comfy/ComfyUI/output"

# cd /workspace/stable-diffusion-webui
# ln -sf ~/scripts/styles.csv .
# ln -sf ~/scripts/webui-user.sh .
#~/goofys postwonder-outputs ~/stable-diffusion-webui/outputs
# rclone mount gdrive:outputs ~/stable-diffusion-webui-forge/outputs --vfs-cache-mode writes --progress --transfers=10 --checkers=8 --drive-chunk-size 64M --no-checksum --fast-list --daemon
rclone mount gdrive:outputs $output_path --vfs-cache-mode writes --progress --transfers=10 --checkers=8 --drive-chunk-size 64M --no-checksum --fast-list --daemon

if [ ! -d "$models_folder" ]; then
	echo "Folder '$models_folder' does not exist.  Creating new folder"
	mkdir -p "$models_folder" # -p creates parent directory if needed
	echo "Folder '$models_folder' created successfully."
	aws s3 cp s3://postwonder-models /workspace/models --recursive
else 
	echo "Folder '$models_folder' already exist."
fi

# sudo aws s3 cp s3://postwonder-extensions/ext.tar.gz /workspace/stable-diffusion-webui
# sudo tar xvf ext.tar.gz
