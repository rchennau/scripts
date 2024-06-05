export MODEL_NAME="stabilityai/stable-diffusion-xl-base-1.0"
export INSTANCE_DIR="/home/ubuntu/.jupyter/train_image"
export OUTPUT_DIR="/workspace/models/Lora/src-workout-2022/"
export VAE_PATH="madebyollin/sdxl-vae-fp16-fix"
# --enable_xformers_memory_efficient_attention \
  #--mixed_precision="fp16" \
  # --push_to_hub \
  # --snr_gamma=5.0
  # --with_prior_preservation \
  # --class_data_dir="/home/ubuntu/diffusers/examples/dreambooth/wandb/latest-run/files/media/images" \
  # --prior_loss_weight=1.0 \
  # --class_prompt="A photo of a young sexy sks asian woman in a sheer kimono" \
  # --resume_from_checkpoint="/workspace/model/Lora/checkpoint-500/" \
  # --report_to="wandb" \
  # --allow_tf32 \

  # --enable_xformers_memory_efficient_attention 
accelerate launch train_dreambooth_lora_sdxl.py \
  --pretrained_model_name_or_path=$MODEL_NAME  \
  --instance_data_dir=$INSTANCE_DIR \
  --pretrained_vae_model_name_or_path=$VAE_PATH \
  --output_dir=$OUTPUT_DIR \
  --instance_prompt="a photo of sks woman" \
  --mixed_precision="fp16" \
  --resolution=1024 \
  --train_batch_size=1 \
  --gradient_accumulation_steps=4 \
  --learning_rate=1e-4 \
  --lr_scheduler="constant" \
  --lr_warmup_steps=0 \
  --max_train_steps=1000 \
  --validation_prompt="A photo of a young sexy sks asian woman in a sheer kimono" \
  --validation_epochs=20 \
  --num_validation_images=2 \
  --gradient_checkpointing \
  --gradient_accumulation_steps=1 \
  --use_8bit_adam \
  --output_kohya_format \
  --report_to="wandb" 
