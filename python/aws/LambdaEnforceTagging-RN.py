#################################################################
# Script to add required tags to EC2 instances in AWS           #
# Lambda is set with 128 MB and 1 minute to timeout             #
# Created by Roger Nem - 2025                                   #
# History:                                                      #
# v0.001 - 04/01/25 - Roger Nem - First Version                 #
#################################################################

import json
import boto3

def lambda_handler(event, context):
    # Parse the Config Rules Compliance Change event
    detail = event['detail']
    resource_id = detail['resourceId']
    resource_type = detail['resourceType']
    compliance_type = detail['newEvaluationResult']['complianceType']
    aws_region = detail['awsRegion']
    account_id = detail['awsAccountId']
    
    # Only process NON_COMPLIANT resources
    if compliance_type == 'NON_COMPLIANT' and resource_type == 'AWS::EC2::Instance':
        try:
            # Initialize EC2 client
            ec2 = boto3.client('ec2', region_name=aws_region)
            
            # Define required tags with specific values
            required_tags = {
                'Project': None,  # Any value is acceptable
                'Purpose': 'Learning',
                'Owner': 'Roger',
                'Environment': 'Production'
            }
            
            # Get existing tags
            response = ec2.describe_tags(
                Filters=[{'Name': 'resource-id', 'Values': [resource_id]}]
            )
            existing_tags = {tag['Key']: tag['Value'] for tag in response['Tags']}
            
            # Determine which tags need to be updated
            tags_to_apply = []
            new_tags = []
            updated_tags = []
            
            for key, required_value in required_tags.items():
                if key not in existing_tags:
                    # Tag doesn't exist
                    tags_to_apply.append({
                        'Key': key,
                        'Value': required_value if required_value is not None else 'DefaultProject'
                    })
                    new_tags.append({'Key': key, 'Value': required_value if required_value is not None else 'DefaultProject'})
                elif required_value is not None and existing_tags[key] != required_value:
                    # Tag exists but has wrong value
                    tags_to_apply.append({
                        'Key': key,
                        'Value': required_value
                    })
                    updated_tags.append({
                        'Key': key,
                        'OldValue': existing_tags[key],
                        'NewValue': required_value
                    })
            
            # Only make API call if there are tags to update
            if tags_to_apply:
                response = ec2.create_tags(
                    Resources=[resource_id],
                    Tags=tags_to_apply
                )
                
                if new_tags:
                    print(f"Applied the following new tags to instance {resource_id}:")
                    for tag in new_tags:
                        print(f"  {tag['Key']}: {tag['Value']}")
                
                if updated_tags:
                    print(f"The following tags were updated for instance {resource_id}:")
                    for tag in updated_tags:
                        print(f"  {tag['Key']}: {tag['OldValue']} -> {tag['NewValue']}")
                    
                return {
                    'statusCode': 200,
                    'body': json.dumps({
                        'message': f'Successfully updated tags for instance {resource_id}',
                        'applied_tags': tags_to_apply
                    })
                }
            else:
                print(f"No tags needed to be updated for instance {resource_id}")
                return {
                    'statusCode': 200,
                    'body': json.dumps('No tag updates required')
                }
            
        except Exception as e:
            print(f"Error applying tags to instance {resource_id}: {str(e)}")
            raise e
    
    else:
        print(f"No action needed for {resource_id} - Compliance status: {compliance_type}")
        return {
            'statusCode': 200,
            'body': json.dumps('No action required')
        }
