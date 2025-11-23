locals {
  vm_names = ["sandbox-1", "sandbox-2"]
  # このTerraform構成で必要な全APIをリスト化
  required_services = [
    "compute.googleapis.com",  # GKEモジュール用
    "storage.googleapis.com",  # GCSモジュール用
    "container.googleapis.com" # GKEモジュール用
  ]
}

# google cloud project
data "google_project" "project" {
  project_id = var.gcp_project_id
}

# 必要なAPIをすべて有効化し待機
module "required_project_services" {
  source = "../../modules/google_project_services"

  project_id        = var.gcp_project_id
  required_services = local.required_services
  wait_seconds      = 60
}

# create the bucket for terraform state
module "tfstate_bucket" {
  source         = "../../modules/tfstate_gcs_bucket"
  gcp_project_id = data.google_project.project.project_id

  depends_on = [module.required_project_services]
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

  depends_on = [module.required_project_services]
}
