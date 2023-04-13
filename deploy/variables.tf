# Specify the target region for deployment
variable "target_region" {
  type        = string
  description = "Target region for deployment"
  default     = "Norway East"
}

variable "container_image" {
  type        = string
  description = "Container image to deploy"
  default     = "ghcr.io/xpiritbv/notes-app"
}

variable "container_image_tag" {
  type        = string
  description = "Container image tag to deploy"
  default     = "latest"
}