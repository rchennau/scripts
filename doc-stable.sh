#!/bin/bash
set -x 								# Enable debug mode in bash
echo on
tmux new-session -d -s docker
tmux send-keys -t docker "sudo aws s3 cp s3://postwonder-models /home/ubuntu/app/data --recursive" Enter # fire and forget 
# tmux send-keys -t docker "sudo chown -R ubuntu:ubuntu /home/ubuntu/app/data" Enter
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
