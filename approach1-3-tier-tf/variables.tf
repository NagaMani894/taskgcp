variable "project_id" {
  type = string
  default ="taskmani-376813"
}

variable "project_number" {
  type = string
  default = "550184559303"
}

variable "region" {
  type = string
  default = "us-west4"
}

variable "zone" {
  type = string
  default = "us-west4-b"
}

variable "basename" {
  type = string
  default = "taskmanigcp"
}

locals {
  sabuild = "${var.project_number}@cloudbuild.gserviceaccount.com"
}

# Handle services
variable "gcp_service_list" {
  description = "The list of apis necessary for the project"
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "cloudapis.googleapis.com",
    "vpcaccess.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudbuild.googleapis.com",
    "sql-component.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "secretmanager.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
  ]
}

variable "build_roles_list" {
  description = "The list of roles that build needs for"
  type        = list(string)
  default = [
    "roles/run.developer",
    "roles/vpaccess.user",
    "roles/iam.serviceAccountUser",
    "roles/run.admin",
    "roles/secretmanager.secretAccessor",
    "roles/artifactregistry.admin",
  ]
}
