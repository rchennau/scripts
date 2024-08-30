import boto3
import time

def start_instance_with_retry(instance_id, max_retries=10):
    """
    Checks the current state of an EC2 instance and attempts to start a specific EC2 instance.

    Args:
        instance_id: The ID of the EC2 instance to start.
        max_retries: The maximum number of retries before giving up.

    Returns:
        True if the instance was started successfully, False otherwise.
    """
    ec2 = boto3.client('ec2')
    response = ec2.describe_instances(InstanceIds=[instance_id])
    current_state = response['Reservations'][0]['Instances'][0]['State']['Name']
    print(f"Current state of instance {instance_id}: {current_state}") 

    if current_state == 'running' and should_stop:
        ec2.stop_instances(InstanceIds=[instance_id])
        printf("Stopping instance {instance_id}...")
        waiter = ec2.get_waiter('instance_stopped')
        waiter.wait(InstanceIds=[instance_id])
        print(f"Instance {instance_id} stopped successfully.")
        
        return True
    elif current_state == 'stopped':
        for attempt in range(1, max_retries + 1):
            try:
                response = ec2.start_instances(InstanceIds=[instance_id])
                print(f"Attempt {attempt}: Starting instance {instance_id}...")

                # Wait for the instance to reach the 'running' state
                waiter = ec2.get_waiter('instance_running')
                waiter.wait(InstanceIds=[instance_id])

                print(f"Instance {instance_id} started successfully!")
                return True

            except Exception as e:
                print(f"Attempt {attempt}: Failed to start instance {instance_id}. Error: {e}")
                time.sleep(5)  # Wait for 5 seconds before retrying

        # If all retries fail, ask the user if they want to continue
        while True:
            continue_choice = input(f"Failed to start after {max_retries} attempts. Continue retrying? (y/n): ")
            if continue_choice.lower() == 'y':
                return start_instance_with_retry(instance_id, max_retries)  # Retry with the same max_retries
            elif continue_choice.lower() == 'n':
                return False
            else:
                print("Invalid input. Please enter 'y' or 'n'.")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Start an EC2 instance with retries.")
    parser.add_argument("-i", "--instance_id", help="The ID of the EC2 instance to start")
    parser.add_argument("-r", "--max-retries", type=int, default=10, help="Maximum number of retries (default: 10)")

    args = parser.parse_args()

    if start_instance_with_retry(args.instance_id, args.max_retries):
        print("Instance started successfully or was alredy running!")
    else:
        print("Failed to start the instance r it's in an invalid state.")
