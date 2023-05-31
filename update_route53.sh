#!/bin/bash

# Replace with your own values
HOSTED_ZONE_ID="Z37WEDFVQ5POLT"
RECORD_NAME="stable.chennault.net"
TTL=60

# Get the public IP address of the dynamic host
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)

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
