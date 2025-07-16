#!/bin/bash
#in app-mvan/ run: 
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
#docker build -t $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/app-book:1.0.2 .
tag="1.0.2"
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/app-book
docker tag $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/app-book:$tag $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/app-book:$tag
docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/app-book:$tag