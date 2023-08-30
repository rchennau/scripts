#!/bin/bash

# Replace with your own values
HOSTED_ZONE_ID="Z37WEDFVQ5POLT"
RECORD_NAME="stable.chennault.net"
DOMAIN_NAME="chennault.net."
CNAME_RECORD="runpod.chennault.net"
RUNPOD_POD_ID=$RUNPOD_POD_ID
TTL=60

# Get the public IP address of the dynamic host
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)
SILENT_MODE=""
if [[ $# -eq 1 && $1 == "-h" ]]; then
    if [[ -z "$2" ]]; then
        echo  "Flag '-h' provided with no arguments.  Setting to usage"
        set -- "-h usage"
    else
        argument=$2
    fi
fi 

if [[ $# -eq 1 && $1 == "-i" ]]; then
    if [[ -z "$2" ]]; then
    set -- "-i interactive"
    fi
else
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

    echo "The new IP address is : "
    aws route53 list-resource-record-sets \
	    --hosted-zone-id $HOSTED_ZONE_ID \
	    --query "ResourceRecordSets[?Name == '$RECORD_NAME'].ResourceRecords[0].Value" \
	    --output text
    exit 1
fi

while getopts "h:r:t:z:a:i" opt; do
    case $opt in
    h) 
        echo "Usage: update_route53.sh [OPTION] [VALUE]" 
        echo "  -h          displays this message"
        echo "  -r          <RECORD_NAME>  example: -r stable.chennault.net"
        echo "  -t          <TTL>  example: -t 60"
        echo "  -z          <HOSTED_ZONE_D>  example: -z Z37WEDFVQ5POLT"
        echo "  -a          <PUBLIC_IP>  example: -a $PUBLIC_IP"
        echo "  -i          use interactive mode"
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
    i) 
        INTERACTIVE_MODE="true"
        ;;
    *) 
        echo "Unknown option $OPTARG"
        exit 1
        ;;
    esac
done

# Ask a lot of questions
    echo "Entering interactive mode"
    read -r -t 5 -p "Set domain [$RECORD_NAME]: " answer
    if [ -z "$answer" ]; then
        echo "Using default: $RECORD_NAME"
        RECORD_NAME="$answer"
    else  
        echo "No record set.  Exiting" 
        exit 1
    fi
# Are we logged into AWS?  If so verify with user they wish to continue with credentials presented
    if aws sts get-caller-identity --no-cli-auto-prompt &> /dev/null
    then
        read -r -t 5 -p "Loggined into AWS as $(aws sts get-caller-identity --output text --query 'UserId' --no-cli-auto-prompt) continue [yes/no]: " answer
        if [ "$answer" = "yes" ]
        then
            echo "Proceeeding with user $(aws sts get-caller-identity --output text --query 'UserId' --no-cli-auto-prompt) "
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