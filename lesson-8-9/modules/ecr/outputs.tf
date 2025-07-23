output "repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.ecr.repository_url
}

output "repository_arn" {
  description = "ARN of the created repository."
  value       = aws_ecr_repository.ecr.arn
}
