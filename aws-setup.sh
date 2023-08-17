#!/bin/bash

#Detect operating system platform
OS=$(uname)
echo "Operating System : $OS"

linux_variant="Unknown"

# package download links
debian_link="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

#Detect if awscli is installed
if command -v aws &>/dev/null; then
	echo "The aws cli is already installed."
else 
	echo "The asw cli is not installed."
	read -p "Do you want to install aws cli (yes/no): " answer
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
                        		sudo apt-get install ./mount-s3.deb
                        		if command -v mount-s3 &>/dev/null; then
                                		echo "The 'aws cli' command is installed."
                                		exit 1
                        		fi
                                		echo "Installation failed. Check for errors."
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
        esac
fi
