import boto3
from datetime import datetime, timedelta

ec2 = boto3.client('ec2')

def lambda_handler(event, context):
    instance_id = 'i-0bb05f8ec68e1912b'
    network_utilization_threshold = 1000 # bytes/second
    idle_time_threshold = 600 # seconds
    
    response = ec2.describe_instances(InstanceIds=[instance_id])
    network_interface_id = response['Reservations'][0]['Instances'][0]['NetworkInterfaces'][0]['NetworkInterfaceId']

    response = ec2.describe_network_interface_attribute(NetworkInterfaceId=network_interface_id, Attribute='attachment')
    eni_id = response['Attachment']['AttachmentId']
    
    response = ec2.get_network_interface_traffic(NetworkInterfaceId=network_interface_id, StartTime=datetime.utcnow() - timedelta(seconds=10), EndTime=datetime.utcnow())
    network_utilization = response['NetworkInterfaceUsage']['BytesInPerSec'] + response['NetworkInterfaceUsage']['BytesOutPerSec']
    
    if network_utilization < network_utilization_threshold:
        # Check if the instance has been idle for more than the idle_time_threshold
        response = ec2.describe_network_interface_attribute(NetworkInterfaceId=network_interface_id, Attribute='attachment')
        attachment_time = response['Attachment']['AttachTime']
        idle_time = datetime.utcnow() - attachment_time
        if idle_time.total_seconds() > idle_time_threshold:
            ec2.stop_instances(InstanceIds=[instance_id])
            print(f"EC2 instance {instance_id} stopped due to inactivity.")
    else:
        print(f"Network utilization of EC2 instance {instance_id} is above threshold.")