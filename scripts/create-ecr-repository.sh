#!/bin/bash

# Script to create ECR repository if it doesn't exist
# Usage: ./scripts/create-ecr-repository.sh [repository-name] [region]

set -e

REPOSITORY_NAME=${1:-"helloworld"}
AWS_REGION=${2:-"us-east-1"}

echo "================================================"
echo "Creating ECR Repository"
echo "================================================"
echo "Repository Name: ${REPOSITORY_NAME}"
echo "AWS Region: ${AWS_REGION}"
echo "================================================"

# Check if repository exists
if aws ecr describe-repositories --repository-names ${REPOSITORY_NAME} --region ${AWS_REGION} 2>&1 | grep -q "RepositoryNotFoundException"; then
    echo "Repository does not exist. Creating..."
    
    aws ecr create-repository \
        --repository-name ${REPOSITORY_NAME} \
        --region ${AWS_REGION} \
        --image-scanning-configuration scanOnPush=true \
        --encryption-configuration encryptionType=AES256
    
    echo "Repository created successfully!"
else
    echo "Repository already exists."
fi

# Get repository URI
REPOSITORY_URI=$(aws ecr describe-repositories --repository-names ${REPOSITORY_NAME} --region ${AWS_REGION} --query 'repositories[0].repositoryUri' --output text)

echo "================================================"
echo "ECR Repository URI: ${REPOSITORY_URI}"
echo "================================================"
