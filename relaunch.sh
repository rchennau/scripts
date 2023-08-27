#!/bin/bash

# Path to the shell script
script="/workspace/stable-diffusion-webui/webui.sh"

while true; do
	  # Run the script in the background
	    $script &

	      # Get the process ID of the script
	        script_pid=$!

		  # Wait for the script to exit
		    wait $script_pid

		      # Check the exit code of the script
		        exit_code=$?

			  # If the script exited with 0, it was successful, exit the monitor script
			    if [ $exit_code -eq 0 ]; then
				        echo "Script exited successfully"
					    exit 0
					      fi

					        # If the script exited with a non-zero exit code, it encountered an error, restart the script
						  echo "Script exited with error code $exit_code. Restarting..."
					  done

