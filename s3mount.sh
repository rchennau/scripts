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
    read -p "Do you want to install mount-s3 (yes/no): " answer
    case $answer in
        y|Y|yes|Yes)
            if [[ "$OS" == "Linux" ]]; then
                echo "Linux detected"
                if [ -f "/etc/os-release" ]; then
                    source /etc/os-release
                    echo "ID_LIKE: $ID_LIKE"
                    if [[ "$ID_LIKE" == "debian" ]]; then
                        linux_variant="Debian"
                        echo "Linux variant: $linux_variant"
                        wget "$debian_link"
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
