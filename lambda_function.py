import json
import boto3
import os

sns_client = boto3.client('sns')
SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):
    print("Received event: ", json.dumps(event, indent=2))
    
    detail = event.get('detail', {})
    event_name = detail.get('eventName', 'Unknown')
    bucket = detail.get('requestParameters', {}).get('bucketName', 'Unknown')
    user = detail.get('userIdentity', {}).get('arn', 'Unknown User')

    message = f"🚨 S3 Alert: {event_name} detected on bucket {bucket}.\nUser: {user}"

    sns_client.publish(TopicArn=SNS_TOPIC_ARN, Subject="S3 Alert", Message=message)

    return {"statusCode": 200, "body": "Notification Sent"}
