# Get the time 24 hours ago
start_time=$(date -d "24 hours ago" +"%Y-%m-%dT%H:%M:%SZ")

# Get the list of files in the current directory
local_files=$(ls -1)

# Create a list of files to copy
sync_files=""

for file in $local_files; do
	if [[ "${file}" -ge "${start_time}" && "${file}" -le "${now}" ]]; then
		sync_files+="${file},"
	fi
done

# Copy the files to S3
aws s3 cp . s3://BUCKET_NAME --exclude "*" --include "${sync_files}"

echo "Files copied successfully."