#!/bin/bash

# Replace with your own values
HOSTED_ZONE_ID="Z37WEDFVQ5POLT"
TTL=60
RECORD_NAME="stable.chennault.net"
DOMAIN_NAME="chennault.net."
HOSTED_ZONE_ID=""
RECORD_NAME="stable.chennault.net."
CNAME_RECORD="runpod.chennault.net"
TTL=60
RUNPOD_POD_ID=$RUNPOD_POD_ID

# Get the public IP address of the dynamic host
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)
SILENT_MODE=""
if [[ $# -eq 1 && $1 -- "-h" ]]; then
    echo  "Flag '-h' privided with no arguments.  Setting to usage"
    argument="usage"
else
    argument=$2
fi
  
while getopts "h:r:t:z:a:s" opt; do
    case $opt in
    h) 
        echo "Usage: ${OPTARG}"
        echo "Exiting"
        exit 1
        ;;
    r) 
        RECORD_NAME="$OPTARG"
        ;;
    t) 
        TTL="$OPTARG"
        ;;
    z) 
        HOSTED_ZONE_ID="$OPTARG"
        ;;
    a) 
        PUBLIC_IP="$OPTARG"
        ;;
    s) 
        SILENT_MODE="true"
        echo "Silent mode set, using defaults"
        if [ -z "$RECORD_NAME" ]
        then
            echo "Default DOMAIN is not set, exiting"
            exit 1
        fi
        ;;
    *) 
        echo "Unknown option $OPTARG"
        exit 1
        ;;
    esac
done
if [ -z $SILENT_MODE ]
then
    echo "Silent mode not set"
    read -r -t 5 -p "Set domain [$RECORD_NAME]: " answer
    if [ -z "$answer" ]; then
        echo "Using default: $RECORD_NAME"
        RECORD_NAME="$answer"
    else  
        echo "No record set.  Exiting" 
        exit 1
    fi
fi

# Are we logged into AWS?  If so verify with user they wish to continue with credentials presented
if aws sts get-caller-identity --no-cli-auto-prompt &> /dev/null
then
    read -r -t 5 -p "Loggined into AWS as $(aws sts get-caller-identity --output text --query 'UserId' --no-cli-auto-prompt) continue [yes/no]: " answer
    if [ "$answer" = "yes" ]
    then
        echo "OK"
    else 
        echo "Exiting."
        exit 1
    fi

else
    echo "Not logged into AWS"
    exit 1
fi

# Get the hosted zone ID
HOSTED_ZONE_ID=$(aws route53 list-hosted-zones --query 'HostedZones[?Name == `'$DOMAIN_NAME'`].Id' --output text | cut -d'/' -f3)

# Ask user for DOMAIN
read -r -t 5 -p "Enter your domain name: [$DOMAIN_NAME] " answer
if [ -n "$answer" ]; then
	echo "The answer was : $answer"
	DOMAIN_NAME=$answer
	echo "Using default domain name $DOMAIN_NAME"
else	
    echo "Why are we here: $DOMAIN_NAME"
fi
    
# Running someplace without an IP?  We got you
# Check if we are runnig on RUNPOD.IO  service
if [ -z "$RUNPOD_POD_ID" ]; then
	# The environment variable is not set
	echo "RUNPOD_POD_ID variable is not set."
	PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)
    	echo "Using $PUBLIC_IP to set A record"
	RECORD_NAME="stable.chennault.net."
    	echo "Using $RECORD_NAME to set A record"
    	echo "HOSTED ZONE ID = $HOSTED_ZONE_ID"
# Update the A record with the new IP address
	aws route53 --no-cli-auto-prompt change-resource-record-sets \
    	--hosted-zone-id $HOSTED_ZONE_ID \
    	--change-batch '{
        	"Changes": [
			{
            			"Action": "UPSERT",
            			"ResourceRecordSet": {
                			"Name": "'$RECORD_NAME'",
                			"Type": "A",
                			"TTL": '$TTL',
                			"ResourceRecords": [
						{
							"Value": "'$PUBLIC_IP'"
						}
					]
            			}
        		}
		]
    }'
else
	# The environment variable is set
	echo "The cname for runpod.io web instance is $RUNPOD_POD_ID"
    	cname_record_value=$RUNPOD_POD_ID."-3001.proxy.runpod.net"
    	echo "$cname_record_value"
    	# Create the change set
    	aws route53 --no-cli-auto-prompt change-resource-record-sets \
        --hosted-zone-id "$HOSTED_ZONE_ID" \
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


echo "The new IP address is : "
aws route53 list-resource-record-sets \
	--hosted-zone-id $HOSTED_ZONE_ID \
	--query "ResourceRecordSets[?Name == '$RECORD_NAME'].ResourceRecords[0].Value" \
	--output text
aws route53 list-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --query "ResourceRecordSets[?Name == '$RECORD_NAME'].ResourceRecords[0].Value" --output text
