#!/bin/bash

# Script to build and push Docker image to AWS ECR
# Usage: ./scripts/push-to-ecr.sh [aws-account-id] [region] [repository-name] [image-tag]

set -e

# Default values
AWS_ACCOUNT_ID=${1:-""}
AWS_REGION=${2:-"us-east-1"}
REPOSITORY_NAME=${3:-"helloworld"}
IMAGE_TAG=${4:-"latest"}

# Validate required parameters
if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo "Error: AWS Account ID is required"
    echo "Usage: ./scripts/push-to-ecr.sh [aws-account-id] [region] [repository-name] [image-tag]"
    exit 1
fi

# ECR repository URL
ECR_REPOSITORY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY_NAME}"

echo "================================================"
echo "Building and Pushing to AWS ECR"
echo "================================================"
echo "AWS Account ID: ${AWS_ACCOUNT_ID}"
echo "AWS Region: ${AWS_REGION}"
echo "Repository Name: ${REPOSITORY_NAME}"
echo "Image Tag: ${IMAGE_TAG}"
echo "ECR Repository: ${ECR_REPOSITORY}"
echo "================================================"

# Step 1: Authenticate Docker to ECR
echo "Step 1: Authenticating Docker to AWS ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# Step 2: Build the Docker image
echo "Step 2: Building Docker image..."
docker build -t ${REPOSITORY_NAME}:${IMAGE_TAG} .

# Step 3: Tag the image for ECR
echo "Step 3: Tagging image for ECR..."
docker tag ${REPOSITORY_NAME}:${IMAGE_TAG} ${ECR_REPOSITORY}:${IMAGE_TAG}

# Step 4: Push the image to ECR
echo "Step 4: Pushing image to ECR..."
docker push ${ECR_REPOSITORY}:${IMAGE_TAG}

echo "================================================"
echo "Successfully pushed image to ECR!"
echo "Image: ${ECR_REPOSITORY}:${IMAGE_TAG}"
echo "================================================"
