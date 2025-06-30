variable "ecr_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "scan_on_push" {
  description = "Enable automatic image scanning"
  type        = bool
  default     = true
}
