#!/bin/bash

cd /workspace/stable-diffusion-webui
ln -sf ~/scripts/styles.csv .
ln -sf ~/scripts/webui-user.sh .
mkdir /workspace/stable-diffusion-webui/outputs
~/goofys postwonder-outputs /workspace/stable-diffusion-webui/outputs
sudo aws s3 cp s3://postwonder-extensions/ext.tar.gz /workspace/stable-diffusion-webui
sudo tar xvf ext.tar.gz
