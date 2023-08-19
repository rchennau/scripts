#!/bin/bash

#Detect operating system platform
OS=$(uname)
echo "Operating System : $OS"

linux_variant="Unknown"

# package download links
debian_link="https://s3.amazonaws.com/mountpoint-s3-release/latest/x86_64/mount-s3.deb"

if command -v mount-s3 &>/dev/null; then
    echo "The 'mount-s3' command is installed."
else
    echo "The 'mount-s3' command is not installed."
    # Reqeust user action and default to yes after 10 seconds and continue
    read -t 10 -p "Do you want to install mount-s3 (yes/no): " answer 
    if [[ -z "$answer" ]]; then
	    answer="yes"
    fi
    case $answer in
        y|Y|yes|Yes)
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
			sudo apt-get -y install ./mount-s3.deb
			if command -v mount-s3 &>/dev/null; then
    				echo "The 'mount-s3' command was successfuly installed."
				echo "Usage: " eval mount-s3
    				echo "Clieaning install."
				rm ./mount-s3.deb
				exit 1
			fi
				echo "Installation failed. Check for errors."
				exit 1
                    fi
                fi
            elif [[ "$OS" == "Darwin" ]]; then
                echo "Apple OS not supported"
                exit 1
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
