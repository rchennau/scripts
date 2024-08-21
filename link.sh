#!/bin/bash

# cd /workspace/stable-diffusion-webui
# ln -sf ~/scripts/styles.csv .
# ln -sf ~/scripts/webui-user.sh .
#~/goofys postwonder-outputs ~/stable-diffusion-webui/outputs
rclone mount gdrive:outputs ~/stable-diffusion-webui-forge/outputs --vfs-cache-mode writes --progress --transfers=10 --checkers=8 --drive-chunk-size 64M --no-checksum --fast-list
mkdir /workspace/models
aws s3 cp s3://postwonder-models /workspace/models
# sudo aws s3 cp s3://postwonder-extensions/ext.tar.gz /workspace/stable-diffusion-webui
# sudo tar xvf ext.tar.gz
