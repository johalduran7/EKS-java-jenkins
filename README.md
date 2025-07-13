step by step.

1. deploy Jenkins https://github.com/johalduran7/Jenkins_ECS_fargate
    change the key_saa
    johnduran@NICE-C02F229ZMD6M:/Users/johnduran/github_john/Jenkins_ECS_fargate/terraform> ssh-keygen -t rsa -b 4096 -f key_saa -N ""

2. Depoy ECR infrastructure for the app-book image
    cd terraform/terraform_ecr
    terraform apply auto-approve

3. 



