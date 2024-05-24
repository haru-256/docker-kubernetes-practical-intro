variable "gcp_project_id" {
  type        = string
  description = "The ID for your GCP project"
}

variable "gcp_region" {
  type        = string
  description = "The region for your GCP project"
}

variable "vpc_network_name" {
  type        = string
  description = "The name of the VPC network"
}

variable "vpc_subnetwork_name" {
  type        = string
  description = "The name of the VPC sub network"
}

variable "router_name" {
  type        = string
  description = "The name of the router"
}

variable "nat_name" {
  type        = string
  description = "The name of the NAT"
}

variable "gke_cluster_name" {
  type        = string
  description = "The name of the GKE cluster"
}
