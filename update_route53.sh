#!/bin/bash

# Replace with your own values
HOSTED_ZONE_ID="Z37WEDFVQ5POLT"
TTL=60
RECORD_NAME="stable.chennault.net"
# Get the public IP address of the dynamic host
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)
SILENT_MODE=""
while getopts ":h:r:t:z:a:s" opt; do
    case $opt in
     h) echo "Usage: ${OPTARG}"
     ;;
     r) RECORD_NAME="$OPTARG"
     ;;
     t) TTL="$OPTARG"
     ;;
     z) HOSTED_ZONE_ID="$OPTARG"
     ;;
     a) PUBLIC_IP="$OPTARG"
     ;;
     s) SILENT_MODE="true"
     ;;
     *) echo "Unknown option $OPTARG"
     esac
done
if [ -z $SILENT_MODE ]
then
    echo "Silent mode not set"
    read -r -t 5 -p "Set domain [$RECORD_NAME]: " answer
    if [ -z "$answer" ]; then
        echo "RECORD_NAME: $answer not entered.  Using default: $RECORD_NAME"
    fi
    RECORD_NAME="$answer"
else
    echo "Silent mode set, using defaults"
    if [ -z "$RECORD_NAME" ]
    then
        echo "Default DOMAIN is not set, exiting"
        exit 1
    fi
fi

# Update the A record with the new IP address
aws route53 change-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --change-batch '{
        "Changes": [{
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'"$RECORD_NAME"'",
                "Type": "A",
                "TTL": '$TTL',
                "ResourceRecords": [{"Value": "'"$PUBLIC_IP"'"}]
            }
        }]
    }'