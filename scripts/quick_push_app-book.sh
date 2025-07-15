#!/bin/bash
#in app-mvan/ run: docker build -t 948586925757.dkr.ecr.us-east-1.amazonaws.com/app-book:1.0.2 .
tag="1.0.2"
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 948586925757.dkr.ecr.us-east-1.amazonaws.com/app-book
docker tag 948586925757.dkr.ecr.us-east-1.amazonaws.com/app-book:$tag 948586925757.dkr.ecr.us-east-1.amazonaws.com/app-book:$tag
docker push 948586925757.dkr.ecr.us-east-1.amazonaws.com/app-book:$tag