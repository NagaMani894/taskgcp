data "google_project" "project" {
  project_id = var.project_id
}

#Allows management of a single API service for a Google Cloud Platform projects

resource "google_project_service" "all" {
  for_each           = toset(var.gcp_service_list)
  project            = var.project_number
  service            = each.value
  disable_on_destroy = false
}

#google_service_account - Allows management of a Google Cloud service account.

resource "google_service_account" "runsa" {
  project      = var.project_number
  account_id   = "${var.basename}-run-sa"
  display_name = "Service Account"
}

#google_project_iam_member - Non-authoritative. Updates the IAM policy to grant a role to a new member. Other members for the role for the project are preserved

resource "google_project_iam_member" "allrun" {
  project    = data.google_project.project.number
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${google_service_account.runsa.email}"
  depends_on = [google_project_service.all]
}


resource "google_project_iam_member" "allbuild" {
  for_each   = toset(var.build_roles_list)
  project    = var.project_number
  role       = each.key
  member     = "serviceAccount:${local.sabuild}"
  depends_on = [google_project_service.all]
}

#The resource random_id generates random numbers that are intended to be used as unique identifiers for other resources.
resource "random_id" "id" {
  byte_length = 2
}

# The following command stores SQL host data in Cloud Secrets.
resource "google_secret_manager_secret" "sqlhost" {
  project = var.project_number
  replication {
    automatic = true
  }
  secret_id  = "sqlhost"
  depends_on = [google_project_service.all]
}

#A secret version resource.

resource "google_secret_manager_secret_version" "sqlhost" {
  enabled     = true
  secret      = "projects/${var.project_number}/secrets/sqlhost"
  secret_data = google_sql_database_instance.main.private_ip_address
  depends_on  = [google_project_service.all, google_sql_database_instance.main, google_secret_manager_secret.sqlhost]
}

#The Service's controller will track the statuses of its owned Configuration and Route, reflecting their statuses and conditions as its own.

resource "google_cloud_run_service" "api" {
  name     = "${var.basename}-api"
  location = var.region
  project  = var.project_id

  template {
    spec {
      service_account_name = google_service_account.runsa.email
      containers {
        image = "nginx"  ################## --------- need to change to correct value ----------------------#####################
        env {
          name = "db_host"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.sqlhost.secret_id
              key  = "latest"
            }
          }
        }
        env {
          name  = "test_name"
          value = "test_values"
        }
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"        = "10"
        "run.googleapis.com/cloudsql-instances"   = google_sql_database_instance.main.connection_name
        "run.googleapis.com/client-name"          = "terraform"
        "run.googleapis.com/vpc-access-egress"    = "all"
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.main.id
      }
    }
  }
  autogenerate_revision_name = true
  
}

#The Service's controller will track the statuses of its owned Configuration and Route, reflecting their statuses and conditions as its own.

resource "google_cloud_run_service" "fe" {
  name     = "${var.basename}-fe"
  location = var.region
  project  = var.project_id

  template {
    spec {
      service_account_name = google_service_account.runsa.email
      containers {
        image = "nginx"  ################## --------- need to change to correct value ----------------------#####################
        ports {
          container_port = 80
        }
      }
    }
  }
}

#Three different resources help you manage your IAM policy for Cloud Run Service.
resource "google_cloud_run_service_iam_member" "noauth_api" {
  location = google_cloud_run_service.api.location
  project  = google_cloud_run_service.api.project
  service  = google_cloud_run_service.api.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_service_iam_member" "noauth_fe" {
  location = google_cloud_run_service.fe.location
  project  = google_cloud_run_service.fe.project
  service  = google_cloud_run_service.fe.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

