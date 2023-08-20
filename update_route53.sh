#!/bin/bash

# Replace with your own values
HOSTED_ZONE_ID="Z37WEDFVQ5POLT"
RECORD_NAME="stable.chennault.net"
TTL=60

# Get the public IP address of the dynamic host
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)

# Running someplace without an IP?  We got you
# Check if we are runnig on RUNPOD.IO container
if [ -z "$RUNPOD_POD_ID" ]; then
	# The environment variable is not set
	echo "The environment variable is not set."
else
	# The environment variable is set
	echo "The cname for runpod.io web instance is $RUNPOD_POD_ID"
    cname_record=$RUNPOD_POD_ID+"-3001.proxy.runpod.net"
    # Create the change set
    change_set=$(aws route53 change-resource-record-sets 

    --hosted-zone-id "${hosted_zone_name}" \
    --change-type CREATE \
    --new-record-sets "{\"Name\": \"${cname_record}", "Type": "CNAME", "TTL": 300, "ResourceRecords": [{"Value": "${cname_record_value}\"}]}")
    # Execute the change set
    aws route53 execute-change-set --change-set-id "${change_set}"
    exit 1
fi

echo "Using IP to set A record"
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
    exit 1
