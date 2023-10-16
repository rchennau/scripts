#!/usr/bin/env bash
cd ~/
git clone https://github.com/rchennau/scripts.git
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cp ~/scripts/styles.csv ~/stable-diffusion-webui/scripts.csv
cp ~/scripts/webui-user.sh ~/stable-diffusion-webui/webui-user.sh
