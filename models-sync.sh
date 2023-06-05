#!/bin/bash

# Set your S3 bucket name and local folder path
S3_BUCKET_NAME="postwonder-models"
LOCAL_FOLDER_PATH="/home/ubuntu/app/data/"

# Function to sync the local folder to S3 bucket
sync_to_s3() {
    aws s3 sync "$LOCAL_FOLDER_PATH" "s3://$S3_BUCKET_NAME"
}

# Watch for new files in the local folder
while true; do
    inotifywait -e create -r "$LOCAL_FOLDER_PATH" && sync_to_s3
done

