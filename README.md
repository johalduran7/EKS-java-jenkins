
# EKS Java App with Jenkins, Gradle, Postgres, and ArgoCD

This project demonstrates a full CI/CD pipeline for a Java Spring Boot application (`app-book`) deployed on Amazon EKS, using Jenkins (on ECS Fargate), ECR, Gradle, Helm, and ArgoCD.

## 1. Deploy Jenkins (ECS Fargate)

Repository: https://github.com/johalduran7/Jenkins_ECS_fargate

Generate SSH key:

```javascript
ssh-keygen -t rsa -b 4096 -f key_saa -N ""
```

## 2. Deploy ECR Infrastructure for `app-book`

```javascript
cd terraform/terraform_ecr
terraform apply -auto-approve
```

## 3. Configure Jenkins Pipeline

Ensure Jenkins is configured to build the project via `Jenkinsfile` using Gradle.

## 4. Deploy EKS Infrastructure

```javascript
cd terraform/terraform_eks
terraform apply -auto-approve
```

## 5. Post-EKS Setup (based on https://github.com/johalduran7/EKS-prometheus-grafana)

### Configure kubectl

```javascript
aws eks update-kubeconfig --region us-east-1 --name eks-cluster-book
```

### Grant IAM Access

```javascript
kubectl get configmap aws-auth -n kube-system -o yaml
kubectl edit configmap aws-auth -n kube-system
```

Add:

```javascript
mapUsers: |
  - userarn: arn:aws:iam::<ACCOUNT_ID>:user/john
    username: john
    groups:
      - system:masters
  - userarn: arn:aws:iam::<ACCOUNT_ID>:root
    username: root-admin
    groups:
      - system:masters
```

### Associate IAM OIDC Provider

```javascript
eksctl utils associate-iam-oidc-provider --region us-east-1 --cluster eks-cluster-book --approve
```

## 6. Deploy PostgreSQL

```javascript
helm install app-book-postgres ./postgres/k8s -f ./postgres/k8s/values.override.yaml -n app-book
```

## 7. Deploy the Java App (`app-book`)

### Authenticate to ECR

```javascript
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
aws ecr get-login-password --region us-east-1 | \
kubectl create secret docker-registry ecr-registry-credentials \
--docker-server=$AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com \
--docker-username=AWS --docker-password=$(aws ecr get-login-password --region us-east-1) \
-n app-book
```

### Deploy with Helm

```javascript
helm install app-book ./app/k8s -f ./app/k8s/values.override.yaml -n app-book
```

To upgrade later:

```javascript
helm upgrade app-book ./app/k8s -f ./app/k8s/values.override.yaml -n app-book
```

## 8. Debugging DB Connection Issues

Run test pod:

```javascript
kubectl run -n app-book debug --rm -it --image=postgres:15 -- bash
```

Install tools:

```javascript
apt update && apt install -y iputils-ping netcat-openbsd postgresql-client
```

Test connection:

```javascript
ping -c 3 postgres-service
nc -zv postgres-service 5432
psql -h postgres-service -U postgres -d john_duran_db
```

## 9. Access the Application

### Port Forward

```javascript
kubectl port-forward service/app-book 8080:8080 -n app-book
```

### Load Balancer

Use the external URL of the LoadBalancer created by the Helm chart.

## 10. Deploy ArgoCD

```javascript
kubectl create namespace argocd
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml -n argocd
kubectl port-forward svc/argocd-server 9091:80 -n argocd
```

Get admin password:

```javascript
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode
```

Deploy ArgoCD Application:

```javascript
kubectl apply -f ArgoCD/app-book-java.yaml -n argocd
```

Check sync status:

```javascript
kubectl get applications -n argocd
```

Attach ECR policy:

```javascript
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

eksctl create iamserviceaccount \
--name argocd-sa \
--namespace argocd \
--cluster eks-cluster-book \
--attach-policy-arn arn:aws:iam::$AWS_ACCOUNT_ID:policy/ECRReadOnlyPolicy \
--approve
```

Patch the ArgoCD deployment:

```javascript
kubectl patch deployment argocd-repo-server -n argocd --type='json' \
-p='[{"op": "add", "path": "/spec/template/spec/serviceAccountName", "value": "argocd-sa"}]'
```

ArgoCD will auto-detect changes such as tag updates:

```javascript
image:
  repository: <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/app-book
  tag: "1.0.1"
  pullPolicy: Always
```

## Cleanup

```javascript
kubectl delete namespace argocd
kubectl delete namespace app-book
```

Then destroy the EKS infrastructure:

```javascript
cd terraform/terraform_eks
terraform destroy -auto-approve
```


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

                if the connection works, something else it's happening with the db driver of the app itself.

6. Access the app:

    1. port forwarding:
        kubectl port-forward service/app-book 8080:8080 -n app-book
    2. classic load balancer:
        check the services and access the load balancer created by the helm char to the app
        be careful with the load balancer, make sure you delete it before you shut down the cluster from terraform, otherwise, it'll keep hanging

7. Deploy ArgoCD

    - create namespace:
        kubectl create namespace argocd
    
    - install argocd:
        kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml -n argocd

    - expose it
        kubectl port-forward svc/argocd-server 9091:80 -n argocd
    
    - get the initial admin password:
        kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode
        e.g.: admin/sQdWUM69Wd7W2nSh
    
    - Configure the app:
        kubectl apply -f ArgoCD/app-book-java.yaml -n argocd
    
    - check that the Application is out of sync:
        kubectl get Applications -n argocd
    
    - Attach the policy to ArgoCD's ServiceAccount:
        AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
        eksctl create iamserviceaccount \
        --name argocd-sa \
        --namespace argocd \
        --cluster eks-cluster-book \
        --attach-policy-arn arn:aws:iam::$AWS_ACCOUNT_ID:policy/ECRReadOnlyPolicy \
        --approve
    
    - Patch the argocd deployment:
        kubectl patch deployment argocd-repo-server -n argocd --type='json' -p='[{"op": "add", "path": "/spec/template/spec/serviceAccountName", "value": "argocd-sa"}]'
    
    - Whenever the tag changes in the manifest, for instance, when CI pipeline pushes a new tag to ECR and updates the manifest of the app, ArgoCD reads it every 3 minutes and shows the changes in Differ, then you can either automatically or manually sync rollout the new tag:
        johnduran@NICE-C02F229ZMD6M:/Users/johnduran/github_john/EKS-java-jenkins> grep -A4 'image:' Kubernetes/app/k8s/values.yaml 
        image:
        repository: <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/app-book
        tag: "1.0.1"
        pullPolicy: always

- Cleanup
    - kubectl delete namespace argocd
    - kubectl delete namespace app-book

    - delete the eksctl stack on CloudFormation created for the serviceaccount of argocd.

    - you can destroy the infrastructure of eks 
        cd terraform/terraform_eks
        terraform destroy -autoa-approve




