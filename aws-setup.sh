#!/bin/bash

#Detect operating system platform
OS=$(uname)
echo "Operating System : $OS"

linux_variant="Unknown"

# package download links
debian_link="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
# Check if the user is root
	if [[ "$(id -u)" == "0" ]]; then
        priveleged_user="apt-get"
		echo "Warning: Running as root user."
    	else
        priveleged_user="sudo apt-get"
		echo "INFO: Running as $(whoami)."
	fi
#Detect if awscli is installed
if command -v aws &>/dev/null; then
	AWS_CLI_VERSION=$(aws --version 2>&1 | awk '{print $1}' | cut -d "/" -f2)
	if [ "$AWS_CLI_VERSION" = "1" ]; then
	echo "The aws cli version $AWS_CLI_VERISON ss installed."
		echo "Removing version awscli version 1"
		sudo rm -rf /usr/local/aws
		sudo rm /usr/local/bin/aws
	fi
	else 
		echo "The asw cli is not installed."
		if command -v unzip &>/dev/null; then
			echo "unzip is not installed.  Required for installing"
		# sudo apt-get -y install unzip
			$priveleged_user -y install unzip 
		fi
	read -r -t 5 -p "Do you want to install aws cli (yes/no): " answer
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
                        		echo "Linux variant: $linux_variant.  Begin Download"
                        		wget "$debian_link"
                        		echo "Begin installation"
								if command -v unzip &>/dev/null; then
									echo "installing unzip."
									sudo apt-get -y install unzip
								fi
                        		unzip "awscli-exe-linux-x86_64.zip"
								sudo ./aws/install
								echo "awscli installed"
								rm -rf aws
								rm awscli-exe-linux-x86_64.zip
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
