#!/bin/bash

#Detect operating system platform
OS=$(uname)
# echo "Operating System : $OS"

linux_variant=""

# package download links

# Check if the user is root
	if [[ "$(id -u)" == "0" ]]; then
        priveleged_user="apt-get"
		echo "Warning: Running as root user."
    else
        priveleged_user="sudo apt-get"
		echo "INFO: Running as $(id -u)."
	fi

# Check if we are running on a G5 instance type
count=$(aws ec2 describe-instances --query 'length(Reservations[*].Instances[*])')
for ((i=1; i<=$count; i++))
do
    instance_type=$(aws ec2 describe-instances --instance-ids --query 'Reservations[].Instances[].InstanceType' --output text)
    if [[ $instance_type == g5* ]]; then
        echo "EC2 instance $i is a g5 type: $instance_type"
        instance_id=$(aws ec2 describe-instances --query 'Reservations[*].Instances[?InstanceType==`g5`].InstanceId' --output text)
    else
        echo "EC2 instance $i is not a g5 type"
        exit 1
    fi
done
# Check if NVME disk is present and mounted 

#Detect if git is installed
if command -v git &>/dev/null; then
	echo "The git cli is already installed."
else 
	echo "The git cli is not installed."
	read -t 5 -p "Do you want to install git cli (yes/no): " answer
	    if [[ -z "$answer" ]]; then
	    	answer="yes"
    	fi
	case $answer in
		y|Y|Yes|yes|YES)
			if [[ "$OS" == "Linux" ]]; then
                	echo "Linux detected"
                	if [ -f "/etc/os-release" ]; then
                    		source /etc/os-release
                    		echo "ID_LIKE: $ID_LIKE"
                    		if [[ "$ID_LIKE" == "debian" ]]; then
                        		linux_variant="Debian"
                        		# echo "Linux variant: $linux_variant.  Begin Download"
                                echo "Begin installation"
                            	$priveleged_user install git
                               if command -v git &>/dev/null; then
                                    if [ -d /workspace]; then 
                                        cd /workspace/
                                        git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git 
                                    else
                                        $priveleged_user mkdir /workspace/
                                        cd /workspace/
                                        git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
                                        $priveleged_user install python3.8-venv
                                        $priveleged_user install google-perftools libgoogle-perftools-dev
                                        /workspace/stable-diffusion-webui/webui.sh


                                    fi
                    		else
                    			echo "OS $linux_variant is currently unsupported"
                    			exit 1
							fi
                   fi
			fi
		;;
		n|N|no|No)
            echo "exiting"
            exit 1
            ;;
        *)
            echo "Invalid input.  Please enter 'yes' or 'no'."
            exit 1
			;;
        esac
fi
