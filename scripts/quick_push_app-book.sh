#!/bin/bash
#docker build -t 948586925757.dkr.ecr.us-east-1.amazonaws.com/app-book:1.0.1 .
tag="1.0.1"
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 948586925757.dkr.ecr.us-east-1.amazonaws.com/app-book
docker tag 948586925757.dkr.ecr.us-east-1.amazonaws.com/app-book:$tag 948586925757.dkr.ecr.us-east-1.amazonaws.com/app-book:$tag
docker push 948586925757.dkr.ecr.us-east-1.amazonaws.com/app-book:$tag