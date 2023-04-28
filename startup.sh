#!/bin/bash
echo on
sudo mkfs -t xfs /dev/nvme1n1
sudo mount /dev/nvme1n1 /home/ubuntu/stable-diffusion/apps
sudo chown -R ubuntu:ubuntu /home/ubuntu/stable-diffusion/apps
sudo apt install python3-venv
cd /home/ubuntu/stable-diffusion/apps
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
#mkdir /home/ubuntu/stable-diffusion/apps/stable-diffusion-webui/outputs
/home/ubuntu/goofys -o nonempty postwonder-outputs /home/ubuntu/stable-diffusion/apps/stable-diffusion-webui/outputs
/home/ubuntu/goofys -o nonempty postwonder-models /home/ubuntu/stable-diffusion/apps/stable-diffusion-webui/models/Stable-diffusion
cp /home/ubuntu/stable-diffusion/apps/stable-diffusion-webui/models/Stable-diffusion/vae* /home/ubuntu/stable-diffusion/apps/stable-diffusion-webui/models/VAE
cp /home/ubuntu/webui-user.sh /home/ubuntu/stable-diffusion/apps/stable-diffusion-webui/
cp /home/ubuntu/sd-start.sh /home/ubuntu/stable-diffusion/apps/stable-diffusion-webui/
cd /home/ubuntu/stable-diffusion/apps/stable-diffusion-webui/extensions
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
#cp ~/startup.sh /home/ubuntu/stable-diffusion/apps/stable-diffusion-webui
touch /home/ubuntu/stable-diffusion/apps/stable-diffusion-webui/webui.log
# Create a new session in tmux named webui and start up webui for stable diffusion
tmux new-session -d -s webui
tmux send-keys -t webui "cd /home/ubuntu/stable-diffusion/apps/stable-diffusion-webui" Enter
tmux send-keys -t webui "python -m venv venv" Enter
tmux send-keys -t webui "/home/ubuntu/stable-diffusion/apps/stable-diffusion-webui/sd-start.sh | tee -a webui.log" Enter
# Attach to the tmux session with the command 
# tmux attach -t webui

# sudo -H -u ubuntu bash -c '/home/ubuntu/stable-diffusion/apps/stable-diffusion-webui/webui.sh --api --listen --no-progressbar-hiding --enable-insecure-extension-access --gradio-auth=Richard:akc2003 --autolaunch --opt-sub-quad-attention --no-hashing --xformers --opt-channelslast --disable-safe-unpickle'
