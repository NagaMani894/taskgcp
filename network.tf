resource "google_compute_network" "main" {
  provider                = google-beta
  name                    = "${var.basename}-private-network"
  auto_create_subnetworks = true
  project                 = var.project_id
}
resource "google_compute_global_address" "main" {
  name          = "${var.basename}-vpc-address"
  provider      = google-beta
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = google_compute_network.main.id
  project       = var.project_id
  depends_on    = [google_project_service.all]
}

resource "google_service_networking_connection" "main" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.main.name]
  depends_on              = [google_project_service.all]
}

resource "google_vpc_access_connector" "main" {
  provider       = google-beta
  project        = var.project_id
  name           = "${var.basename}-vpc-cx"
  ip_cidr_range  = "10.8.0.0/28"
  network        = google_compute_network.main.id
  region         = var.region
  max_throughput = 300
  depends_on     = [google_compute_global_address.main, google_project_service.all]
}
