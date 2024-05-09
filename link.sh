#!/bin/bash

# cd /workspace/stable-diffusion-webui
# ln -sf ~/scripts/styles.csv .
# ln -sf ~/scripts/webui-user.sh .
~/goofys postwonder-outputs ~/stable-diffusion-webui/outputs
mkdir /workspace/models
aws s3 cp s3://postwonder-models /workspace/models
~/goofys postwonder-outputs /workspace/stable-diffusion-webui/outputs
# sudo aws s3 cp s3://postwonder-extensions/ext.tar.gz /workspace/stable-diffusion-webui
# sudo tar xvf ext.tar.gz
