docker run --gpus all --restart always --name diffusion_webui -d \
    -v /home/ubuntu/apps/stable-diffusion-webui/models:/app/models \
    -v /home/ubuntu/apps/stable-diffusion-webui/outputs:/app/outputs \
    -v /home/ubuntu/apps/stable-diffusion-webui/extensions:/app/extensions \
    -v /home/ubuntu/apps/stable-diffusion-webui/configs:/app/configs \
    -v /home/ubuntu/apps/stable-diffusion-webui/others:/tmp/others \
    -p 7860:7860 \
   bobzhao1210/diffusion-webui
python webui.py --listen --no-download-sd-model --enable-insecure-extension-access --api --xformers --opt-split-attention --no-progressbar-hiding --enable-insecure-extension-access --share --autolaunch --opt-sub-quad-attention --no-hashing --opt-channelslast --disable-safe-unpickle --cors-allow-origins=https://stable.chennault.net:7860
