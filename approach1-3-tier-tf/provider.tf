terraform {
  backend "gcs" {
    bucket  = "taskstatefilegcpmani"
    prefix  = "terraform/state"
  }
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
    
}
