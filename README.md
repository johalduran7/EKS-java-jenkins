
# EKS Java App with Jenkins, Maven, Postgres, and ArgoCD

This project demonstrates a full CI/CD pipeline for a Java Spring Boot application (`app-book`) deployed on Amazon EKS, using Jenkins (on ECS Fargate), ECR, Maven, Helm, and ArgoCD.

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

Ensure Jenkins is configured to build the project via `Jenkinsfile` using Maven.

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

## 6. Create Secrets, ConfigMaps, and namespace for the project

create Namespace:
```javascript
kubetl create namespace app-book
```

update the file secrets/secrets.override.yaml with the configMap values and Secrets. For secrets, encode them into base64 format.
```javascript
echo -n "value" | base64

```

create Secrets and ConfigMaps
```javascript
kubetl apply -f secrets/secrets.override.yaml
```


## 7. Deploy PostgreSQL

```javascript
helm install app-book-postgres ./postgres/k8s -f ./postgres/k8s/values.override.yaml -n app-book
```

## 8. Deploy the Java App (`app-book`)

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

## 9. Debugging DB Connection Issues

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

## 10. Access the Application

### Port Forward

```javascript
kubectl port-forward service/app-book 8080:8080 -n app-book
```

### Load Balancer

Use the external URL of the LoadBalancer created by the Helm chart.

## 11. Deploy ArgoCD

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
