#################################################################
# Script to Stop Running EC2 instances in AWS                   #
# Lambda is set with 128 MB and 1 minute to timeout             #
# Created by Roger Nem - 2025                                   #
# History:                                                      #
# v0.001 - 02/26/25 - Roger Nem - First Version                 #
#################################################################

# Import AWS SDK for Python
import boto3

def lambda_handler(event, context):
    # Create EC2 client for us-east-1 region
    ec2 = boto3.client('ec2', region_name='us-east-1')
    
    # Get all EC2 instances
    instances = ec2.describe_instances()
    
    # Iterate through reservations and instances
    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            # Check if instance is in running state
            if instance['State']['Name'] == 'running':
                # Stop the running instance
                ec2.stop_instances(InstanceIds=[instance['InstanceId']])
                print('Stopped instance: ', instance['InstanceId'])
                
    # Return success response
    return {
        'statusCode': 200,
        'body': 'EC2 instances stopped successfully'
    }
