#!/bin/bash

export AWS_ACCESS_KEY_ID=$1
export AWS_SECRET_ACCESS_KEY=$2
export AWS_SECURITY_TOKEN=$3

SourceFilePath=$4
DestinationBucket=$5

echo "Source File path: $SourceFilePath"
echo 
echo "Destination S3 Bucket Name: $DestinationBucket"

aws s3 cp $SourceFilePath s3://$DestinationBucket/application/ --recursive --acl bucket-owner-full-control

