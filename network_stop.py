import boto3
from datetime import datetime, timedelta


# Test if instance id is up
ec2 = boto3.client('ec2')
# Retrieve information about the instance
response = ec2.describe_instances(
    Filters=[
        {
            'Name': 'instance-state-name',
            'Values': ['running']
        }
    ]
)
if len(response['Reservations']) > 0:
    instance_id = response['Reservations'][0]['Instances'][0]['InstanceId']
    run_state = response['Reservations'][0]['Instances'][0]['State']['Name']
    print(f'Instance ID: {instance_id}')
    print(f'Run state: {run_state}')

    # Set up the CloudWatch client
    cloudwatch = boto3.client('cloudwatch')

    # Define the network utilization metric
    metric_name = 'NetworkIn'
    namespace = 'AWS/EC2'
    dimensions = [{'Name': 'InstanceId', 'Value': 'i-0bb05f8ec68e1912b'}]

    # Get the network utilization metric for the last 15 minutes    
    end_time = datetime.utcnow()
    start_time = end_time - timedelta(hours=1)
    response = cloudwatch.get_metric_data(
      MetricDataQueries=[
         {
                'Id': 'm1',
               'MetricStat': {
                   'Metric': {
                       'Namespace': namespace,
                      'MetricName': metric_name,
                      'Dimensions': dimensions
                  },
                  'Period': 15,
                 'Stat': 'Sum',
              },
              'ReturnData': True,
         },
      ],
      StartTime=start_time,
      EndTime=end_time,
    )

    # Extract the network utilization value
    if len(response['MetricDataResults'][0]['Values']) > 0:
        network_in = response['MetricDataResults'][0]['Values'][-1]
        print(f'Network utilization for instance <instance-id>: {network_in}')
    else:
        print(f'No network utilization data found for instance <instance-id>')
else:
    print('No running instances found')
