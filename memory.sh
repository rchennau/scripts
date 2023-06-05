#!/bin/bash

# Define the memory threshold (in percentage)
MEMORY_THRESHOLD=3

# Continuously monitor available memory
while true; do
  # Get the current available memory percentage
  AVAILABLE_MEMORY=$(free | awk '/^Mem/ {print $4/$2 * 100.0}') 
  echo "$AVAILABLE_MEMORY and $MEMORY_THRESHOLD"
  # Check if available memory falls below the threshold
  if (( $(echo "$AVAILABLE_MEMORY < $MEMORY_THRESHOLD" | bc -l) )); then
    # Get the process ID (PID) of the highest memory-using process
    PID=$(ps -eo pid,%mem --sort=-%mem | awk 'NR==2 {print $1}')
	echo "$PID"
    # Send a HUP signal to the process
    if [[ -n $PID ]]; then
      echo "Available memory below threshold. Sending HUP signal to process $PID."
      # docker stop diffusion_webui
      # docker start diffusion_webui 
      sudo echo 3 > /proc/sys/vm/drop_caches clear cache
      # sudo kill -HUP $PID
    fi
  fi

  # Sleep for a desired interval before checking memory again (e.g., every 5 seconds)
  sleep 5
done
