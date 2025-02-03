import logging
import botocore
import boto3
from botocore.exceptions import ClientError
import json
my_bucket = 'ayushjoshi2004867'
my_region = 'ap-south-1'

s3_client = boto3.client('s3')

def create_bucket(bucket_name, region=None):
    try:
        if region is None:
            s3_client.create_bucket(Bucket=bucket_name)
        else:
            location = {'LocationConstraint': region}
            s3_client.create_bucket(Bucket=bucket_name, CreateBucketConfiguration=location)
    except ClientError as e:
        logging.error(e)
        return False
    return True
#create_bucket(my_bucket, my_region)


def check_policy():
    try:
        result = s3_client.get_bucket_acl(Bucket=my_bucket)
        print('Bucket ACL :- ')
        print(result)
        print('\n')
        print('Bucket Policy :- ')
        mybucketpolicy = s3_client.get_bucket_policy(Bucket=my_bucket)
        print(mybucketpolicy['Policy'])
    except ClientError as e:
        if e.response['Error']['Code'] == 'NoSuchBucketPolicy':
            print(f"No policy found for bucket: {my_bucket}.")
        else:
            raise
check_policy()

def set_policy(bucket_name):
    try:
        s3_client.get_bucket_policy(Bucket=bucket_name)
    except botocore.exceptions.ClientError as e:
        if e.response['Error']['Code'] == 'NoSuchBucketPolicy':
            print(f"No policy found for bucket: {bucket_name}. Setting a new policy.")
        else:
            raise

    bucket_policy = {
        "Id": "Policy1738607299975",
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "Stmt1738607288707",
                "Action": "s3:*",
                "Effect": "Allow",
                "Resource": f"arn:aws:s3:::{bucket_name}/*",
                "Principal": "*"
            }
        ]
    }
    bucket_policy_json = json.dumps(bucket_policy)
    s3_client.put_bucket_policy(Bucket=bucket_name, Policy=bucket_policy_json)
    print(f"Policy set for bucket: {bucket_name}")

#set_policy(my_bucket)