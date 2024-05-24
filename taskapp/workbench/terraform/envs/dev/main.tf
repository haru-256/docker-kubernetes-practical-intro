# google cloud project
data "google_project" "project" {
  project_id = var.gcp_project_id
}

# create the bucket for terraform state
module "tfstate_bucket" {
  source         = "../../modules/tfstate_gcs_bucket"
  gcp_project_id = data.google_project.project.project_id
}

# GKE
module "gke" {
  source              = "../../modules/gke"
  gke_cluster_name    = "sandbox"
  gcp_project_id      = data.google_project.project.project_id
  gcp_region          = var.gcp_default_region
  vpc_network_name    = "gke-sandbox"
  vpc_subnetwork_name = "gke-sandbox-${var.gcp_default_region}"
  router_name         = "gke-sandbox"
  nat_name            = "gke-sandbox"
}
