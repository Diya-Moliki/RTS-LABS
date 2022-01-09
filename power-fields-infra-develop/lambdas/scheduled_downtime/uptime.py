import boto3
import os

## Setting variables and importing libraries.
region = "us-east-1"
client = boto3.client('ecs', region_name=region)

# CLUSTER_NAME = "pf-nonprod"
SERVICE_NAME = [
    "powerfields-dev-rts",
    "powerfields-qa-reg",
    "powerfields-demo-rts"
    ]

def lambda_handler(event, context):
    print("----- STARTING -----")
    for s in SERVICE_NAME:
        response = client.update_service(
            cluster="pf-nonprod",
            service=s,
            desiredCount=2,
            forceNewDeployment=False,
            deploymentConfiguration={
                'maximumPercent': 200,
                'minimumHealthyPercent': 50
            }
        )
        print("Updated " + s + " to 2 desired tasks")
    
    # Perf cluster and service
    response = client.update_service(
        cluster="pf-perf",
        service="powerfields-perf-rts",
        desiredCount=2,
        forceNewDeployment=False,
        deploymentConfiguration={
            'maximumPercent': 200,
            'minimumHealthyPercent': 50
        }
    )
    print("Updated powerfields-perf-rts to 2 desired tasks")
    print("----- FINISHED -----")
