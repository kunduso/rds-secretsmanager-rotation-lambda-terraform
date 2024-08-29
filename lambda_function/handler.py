import boto3
import logging
import time
import os
from botocore.config import Config

logger = logging.getLogger()
logger.setLevel(os.environ['LOG_LEVEL'])

def log_cloudwatch(log_group_name,log_stream_name,message):
    # Initialize the Boto3 clients  CloudWatch Logs
    logs_client = boto3.client('logs')
    try:

        # Write the parameter value to CloudWatch Logs
        logs_client.put_log_events(
            logGroupName=log_group_name,
            logStreamName=log_stream_name,
            logEvents=[
                {
                    'timestamp': int(round(time.time() * 1000)),
                    'message': f"{message}"
                }
            ]
        )

    except Exception as e:
        logging.error(f"An error occurred: {e}")

# connect_timeout = int(os.environ['API_CONNECT_TIMEOUT']) if 'API_CONNECT_TIMEOUT' in os.environ else 2
# read_timeout = int(os.environ['API_READ_TIMEOUT']) if 'API_READ_TIMEOUT' in os.environ else 2
# retries = int(os.environ['API_RETRIES']) if 'API_RETRIES' in os.environ else 5

# config = Config(
#   connect_timeout=connect_timeout,
#   read_timeout=read_timeout,
#   retries = {
#     'max_attempts': retries,
#     'mode': 'standard'
#   }
# )

def lambda_handler(event, context):
    # Initialize the Boto3 clients  CloudWatch Logs
    # Setup the client
    #service_client = boto3.client('secretsmanager', config=config, endpoint_url=os.environ['SECRETS_MANAGER_ENDPOINT'])
    secret_arn = event['SecretId']
    log_group_name = os.environ['log_group_name']
    log_stream_name = os.environ['log_stream_name']
    try:
        log_cloudwatch(log_group_name, log_stream_name, secret_arn)
    except Exception as e:
        logging.error(f"An error occurred: {e}")