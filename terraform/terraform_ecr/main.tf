resource "aws_ecr_repository" "app-book" {
  name                 = "${var.ecr_repo_name}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}


resource "aws_ecr_lifecycle_policy" "ecr_app-book-policy" {
  repository = aws_ecr_repository.app-book.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep only the latest two images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}


# Null resource to build and push the Docker image
resource "null_resource" "build_and_push_app-book-image" {
  triggers = {
    # Rebuild the image if the Dockerfile changes
    dockerfile_hash = filemd5("${var.app_path}/Dockerfile")
    app_js_hash     = filemd5("${var.app_path}/target/app-book*.jar")
  }

  provisioner "local-exec" {
    command = <<EOT
      # Authenticate Docker to ECR
      aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.app-book.repository_url}

      # Build the Docker image
      docker build -t ${aws_ecr_repository.app-book.repository_url}:${var.image_tag} -f ${var.app_path}/Dockerfile ${var.app_path}/

      # Push the Docker image to ECR
      docker push ${aws_ecr_repository.app-book.repository_url}:${var.image_tag}
    EOT
  }

}