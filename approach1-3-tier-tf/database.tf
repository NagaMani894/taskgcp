resource "google_sql_database_instance" "main" {
  depends_on = [
    google_project_service.all,
    google_service_networking_connection.main
  ]
  name             = "${var.basename}-db-${random_id.id.hex}"
  database_version = "MYSQL_5_7"
  region           = var.region
  project          = var.project_id
  settings {
    tier                  = "db-g1-small"
    disk_autoresize       = true
    disk_autoresize_limit = 0
    disk_size             = 10
    disk_type             = "PD_SSD"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.main.id
    }
    location_preference {
      zone = var.zone
    }
  }
  deletion_protection = false
  
}