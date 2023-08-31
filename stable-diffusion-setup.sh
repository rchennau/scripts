#!/bin/bash

#Detect operating system platform
OS=$(uname)
# echo "Operating System : $OS"
id=$(id -u)
linux_variant=""
priveledge_user=""

# package download links

# Check if the user is root
	if [[ "$(id -u)" == "0" ]]; then
        priveleged_user="Warning: running as root: "
		echo "Warning: Running as root user."
    else
        priveleged_user="sudo"
		echo "INFO: Running as $(id -u)."
	fi

# Check if we are running on a G5 instance type
count=$(aws ec2 describe-instances --query 'length(Reservations[*].Instances[*])')
for ((i=1; i<=$count; i++))
do
    instance_type=$(aws ec2 describe-instances --instance-ids --query 'Reservations[].Instances[].InstanceType' --output text)
    if [[ $instance_type == g5* ]]; then
	    instance_id=$(aws ec2 describe-instances --query 'Reservations[].Instances[?contains(InstanceType, `g5.`)].InstanceId' --output text)
        echo "EC2 instance $instance_id is a g5 type: $instance_type"
    else
        echo "EC2 instance $instance_id is not a g5 type"
        exit 1
    fi
done
##### ENVIRONMENT SETUP #####
#  Detect if git is installed

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
                            	$priveleged_user apt-get install git
                                if command -v git &>/dev/null; then
                                    echo "git installed.  Continuing installation"
                                fi
                    		else
                    			echo "OS $linux_variant is currently unsupported"
                    			exit 1
							fi
                   fi
			fi
        ;;
        n|N|no|no)
            echo "Exiting"
            exit 1
            ;;
            *)
            echo "Input not valid"
            exit 1
            ;;
    esac
fi
            
            
#            if [ -d $sd_mount]; then 
#                cd $sd_mount
#                git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git 
#            else
#                if [ -d $sd_mount ]; then
#                    cd $sd_mount
#                    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
#                    # SD works with python3.8 but newer extensions like 3.10.  On Ubuntu that is a heavy refactor 
#                    if command -v python3.8 &>/dev/null; then
#                        echo "Python 3.8 is already installed.  Continuing installation"
#                    else 
#                        $priveleged_user apt-get install python3.8-venv
#                        $priveleged_user apt-get install google-perftools libgoogle-perftools-dev
#                    fi
#### Setup Python 3.10 ####
if command -v python3.10 &>/dev/null; then
    echo "Python 3.10 is already installed.  Continuing installation"
else 
    $priveledge_user add-apt-repository ppa:deadsnakes/ppa
    $priveledge_user apt-get update
    $priveledge_user apt-get install python3.10
    $priveledge_user update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1
    $priveledge_user update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 2
    # Add code to fix pip now that python3.10 is installed
    $priveledge_user apt remove --purge python3-apt
    $priveledge_user apt autoclean
    $priveledge_user apt install python3-apt
    $priveledge_user apt install python3.10-distutils
    $priveledge_user python3.10 get-pip.py
    $priveledge_user apt install python3.10-venv
    # run webui.sh and cross fingers!
    if command -v pip --version &>dev/null; then
        echo "Upgrade to python3.10 failed"
    fi
fi