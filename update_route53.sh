#!/bin/bash

# Replace with your own values
DOMAIN_NAME="chennault.net."
HOSTED_ZONE_ID=""
RECORD_NAME="stable.chennault.net."
CNAME_RECORD="runpod.chennault.net"
TTL=60
RUNPOD_POD_ID="$RUNPOD_POD_ID"

# Get the public IP address of the dynamic host
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)

# Get the hosted zone ID
HOSTED_ZONE_ID=$(aws route53 list-hosted-zones --query 'HostedZones[?Name == `'$DOMAIN_NAME'`].Id' --output text | cut -d'/' -f3)

# Ask user for DOMAIN
read -t 5 -p "Enter your domain name: [$DOMAIN_NAME] " answer
if [ -z "$answer" ]; then
    echo "Using default domain name $DOMAIN_NAME"

else
    DOMAIN_NAME="$answer"
fi
    
# Running someplace without an IP?  We got you
# Check if we are runnig on RUNPOD.IO container
if [ -z "$RUNPOD_POD_ID" ]; then
	# The environment variable is not set
	echo "The environment variable is not set."
else
	# The environment variable is set
	echo "The cname for runpod.io web instance is $RUNPOD_POD_ID"
    cname_record_value=$RUNPOD_POD_ID."-3001.proxy.runpod.net"
    echo $cname_record_value
    # Create the change set
    aws --debug route53 change-resource-record-sets \
        --hosted-zone-id $HOSTED_ZONE_ID \
        --change-batch '{
            "Changes":[{
                "Action": "UPSERT",
                "ResourceRecordSet": {
                    "Name": "'$CNAME_RECORD'",
                    "Type": "CNAME",
                    "TTL":300,
                    "ResourceRecordSet": [{
                        "Value": "'$cname_record_value'"
                    }]
                }
            }]
        }'
    exit 1
fi

echo "Using $PUBLIC_IP to set A record"
# Update the A record with the new IP address
aws route53 change-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --change-batch '{
        "Changes": [{
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$RECORD_NAME'",
                "Type": "A",
                "TTL": '$TTL',
                "ResourceRecords": [{"Value": "'$PUBLIC_IP'"}]
            }
        }]
    }' 
sleep 5
# echo "The new IP address is"; aws route53 list-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --query "ResourceRecordSets[?Name == '$RECORD_NAME'].ResourceRecords[0].Value" --output text
result=$(aws route53 list-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --query "ResourceRecordSets[?Name == '$RECORD_NAME'].ResourceRecords[0].Value" --output text)  && echo "The A record updated successfuly tohost $result"

