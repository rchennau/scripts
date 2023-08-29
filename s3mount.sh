#!/bin/bash

#Detect operating system platform
<<<<<<< HEAD
OS=$(uname)
=======
# OS=$(uname)
>>>>>>> master
echo "Operating System : $OS"

linux_variant="Unknown"

# package download links
debian_link="https://s3.amazonaws.com/mountpoint-s3-release/latest/x86_64/mount-s3.deb"
<<<<<<< HEAD
# Check if the user is root
	if [[ "$(id -u)" == "0" ]]; then
        priveleged_user="apt-get"
		echo "Warning: Running as root user."
    else
        priveleged_user="sudo apt-get"
		echo "INFO: Running as $(id -F)."
	fi
=======

>>>>>>> master
if command -v mount-s3 &>/dev/null; then
    echo "The 'mount-s3' command is installed."
else
    echo "The 'mount-s3' command is not installed."
<<<<<<< HEAD
    # Reqeust user action and default to yes after 10 seconds and continue
    read -t 10 -p "Do you want to install mount-s3 (yes/no): " answer 
    if [[ -z "$answer" ]]; then
	    answer="yes"
    fi
=======
    read -p "Do you want to install mount-s3 (yes/no): " answer
>>>>>>> master
    case $answer in
        y|Y|yes|Yes)
            if [[ "$OS" == "Linux" ]]; then
                echo "Linux detected"
                if [ -f "/etc/os-release" ]; then
                    source /etc/os-release
<<<<<<< HEAD
                    echo "ID_LIKE: $ID_LIKE"
                    if [[ "$ID_LIKE" == "debian" ]]; then
                        linux_variant="Debian"
                        echo "Linux variant: $linux_variant.  Begin Download"
                        wget "$debian_link"
			echo "Begin installation"
			$priveleged_user -y install ./mount-s3.deb
			if command -v mount-s3 &>/dev/null; then
    				echo "The 'mount-s3' command was successfuly installed."
				echo "Usage: " eval mount-s3
    				echo "Clieaning install."
				rm ./mount-s3.deb
				exit 1
			fi
				echo "Installation failed. Check for errors."
				exit 1
=======
                    if [[ "SID" == "debian" ]]; then
                        linux_variant="Debian"
                        echo "Linux variant: $linux_variant"
                        wget "$debian_link"
>>>>>>> master
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
<<<<<<< HEAD
fi
=======
fi
>>>>>>> master
