step by step.

1. deploy Jenkins https://github.com/johalduran7/Jenkins_ECS_fargate
    change the key_saa
    johnduran@NICE-C02F229ZMD6M:/Users/johnduran/github_john/Jenkins_ECS_fargate/terraform> ssh-keygen -t rsa -b 4096 -f key_saa -N ""

2. Depoy ECR infrastructure for the app-book image
    cd terraform/terraform_ecr
    terraform apply auto-approve

3. Configure the pipeline to run Jenkins/mvn/Jenkinsfile or Gradle

4. Deploy the infrastructure for EKS: 
    cd terraform/terraform_eks
    terraform apply -auto-approve

5. The following steps are based in the complete guide for EKS: https://github.com/johalduran7/EKS-prometheus-grafana/tree/master

    - Basic setup

        - Configure Kubectl
          aws eks update-kubeconfig --region us-east-1 --name eks-cluster-book
        
        - Grant IAM user permissions to see EKS resources.
            kubectl get configmap aws-auth -n kube-system -o yaml

                add by editing the file kubectl edit configmap aws-auth -n kube-system:
                    mapUsers: |
                    - userarn: arn:aws:iam::<ACCOUNT_ID>:user/john
                        username: john
                        groups:
                        - system:masters
                    - userarn: arn:aws:iam::<ACCOUNT_ID>:root
                        username: root-admin
                        groups:
                        - system:masters
        
        - Create IAM OIDC provider:
              eksctl utils associate-iam-oidc-provider --region us-east-1 --cluster eks-cluster-book --approve
                

    - Deploy Postgres
        - go to Kubernetes folder and deploy postgres as follows:
            helm install app-book-postgres ./postgres/k8s -f ./postgres/k8s/values.override.yaml -n app-book
        
    - Deploy app-book:
        - authenticate to ECR for the app-book deployment to be able to pull the image from the registry
            AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
            aws ecr get-login-password --region us-east-1 | \
            kubectl create secret docker-registry ecr-registry-credentials \
            --docker-server=$AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com \
            --docker-username=AWS --docker-password=$(aws ecr get-login-password --region us-east-1) \
            -n app-book
        
        - deploy the application:
            helm install app-book ./app/k8s -f ./app/k8s/values.override.yaml -n app-book

            if you need to upgrade:
                helm upgrade app-book ./app/k8s -f ./app/k8s/values.override.yaml -n app-book
            
            - troubleshoot issues with connection to db:
                run a temporary pod:
                    kubectl run -n app-book debug --rm -it --image=postgres:15 -- bash
                install dependencies an plsql
                    apt update && apt install -y iputils-ping netcat-openbsd postgresql-client
                
                test connection:
                    ping -c 3 postgres-service
                    nc -zv postgres-service 5432
                    psql -h postgres-service -U postgres -d john_duran_db





