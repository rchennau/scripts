export INSTANCE_DIR="/home/ubuntu/stable-diffusion-webui/outputs/training_data_sets"
export MODEL_NAME="RunDiffusion/Juggernaut-X-v10"
#  --dataset_name="PostWonder/srcy_v5" \
#  --enable_xformers_memory_efficient_attention \
accelerate launch train_dreambooth_lora_sdxl.py \  
  --dataset_name="PostWonder/srcy_v5" \
  --instance_data_dir=$INSTANCE_DIR \
  --caption_column="prompt" \
  --instance_prompt="photo of a srcy woman" \
  --train_text_encoder \
  --mixed_precision="fp16" \
  --pretrained_model_name_or_path=$MODEL_NAME \
  --pretrained_vae_model_name_or_path="madebyollin/sdxl-vae-fp16-fix" \
  --resolution="1024" \
  --train_batch_size=1 \
  --gradient_accumulation_steps=3 \
  --gradient_checkpointing \
  --learning_rate=1e-4 \
  --snr_gamma=5.0 \
  --lr_scheduler="constant" \
  --lr_warmup_steps=0 \
  --use_8bit_adam \
  --max_train_steps=1200 \
  --checkpointing_steps=717 \
  --seed="0" \
  --output_dir="/workspace/models/lora/srcy_v6" \
  --output_kohya_format \
  --local_rank=128 \
  --report_to="wandb" \
  --enable_xformers_memory_efficient_attention 
