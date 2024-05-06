# allow to use the google cloud service api
resource "google_project_service" "services" {
  for_each = toset([
    "compute.googleapis.com", "container.googleapis.com", "storage.googleapis.com"
  ])

  project            = var.gcp_project_id
  service            = each.value
  disable_on_destroy = true
}

# VPC
resource "google_compute_network" "gke" {
  name                    = var.vpc_network_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# Subnet1(asia-northeast1)
# 以下のノード、Pod、Service の IP アドレス範囲の概要を参照しながら必要なip address範囲を設定する
# https://cloud.google.com/kubernetes-engine/docs/concepts/alias-ips?hl=ja#cluster_sizing
resource "google_compute_subnetwork" "gke" {
  name          = var.vpc_subnetwork_name
  ip_cidr_range = "10.16.0.0/12"
  region        = var.gcp_region
  network       = google_compute_network.gke.id

  secondary_ip_range = [
    {
      range_name    = "pods"
      ip_cidr_range = "10.32.0.0/14"
    },
    {
      range_name    = "services"
      ip_cidr_range = "10.48.0.0/20"
    }
  ]
}

# GKE cluster(Autopilot)
# 以下を参考に設定を行う
# https://zenn.dev/btc4043/articles/28f4b326b04762#gke-%E3%82%AF%E3%83%A9%E3%82%B9%E3%82%BF%EF%BC%88autopilot%E3%83%A2%E3%83%BC%E3%83%89%EF%BC%89
# https://blog.g-gen.co.jp/entry/private-gke-made-with-terraform
# また、VPCネイティブモードは以下が参考になる
# https://medium.com/google-cloud-jp/gke-vpc-native-related-docs-1ec7a82fa719
# https://medium.com/google-cloud-jp/gke-network-basic-8a22be15517d
resource "google_container_cluster" "sandbox" {
  name = var.gke_cluster_name

  enable_autopilot = true
  location         = var.gcp_region
  deletion_protection = false

  release_channel {
    channel = "STABLE"
  }

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {
    cluster_secondary_range_name  = google_compute_subnetwork.gke.secondary_ip_range[0].range_name
    services_secondary_range_name = google_compute_subnetwork.gke.secondary_ip_range[1].range_name
  }

  network    = google_compute_network.gke.self_link
  subnetwork = google_compute_subnetwork.gke.self_link

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "192.168.100.0/28"

    master_global_access_config {
      enabled = true
    }
  }

  # 外部からのアクセスを許可しないためには以下の設定が必要
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#master_authorized_networks_config
  # master_authorized_networks_config {
  # }

  maintenance_policy {
    recurring_window {
      start_time = "2022-04-29T17:00:00Z"
      end_time   = "2022-04-29T21:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=FR,SA,SU"
    }
  }

  node_config {
    metadata = {
      disable-legacy-endpoints = true
    }
    # autopilotはdefault でworkload identityが設定されるため不要だろう。しかし、設定しなけばtrivyのlint errorが発生する
    # https://avd.aquasec.com/misconfig/google/gke/avd-gcp-0057/
    workload_metadata_config {
      mode = "GCE_METADATA"
    }

  }
  # autopilotはdefault でworkload identityが設定されるため設定不要。設定すると以下のようなエラーが発生する
  # "workload_identity_config": conflicts with enable_autopilot
  # workload_identity_config {
  #   workload_pool = "${var.gcp_project_id}.svc.id.goog"
  # }

  # node_configを設定すると毎planでdestroy&createされるため、以下の設定を行う。
  # reservation_affinityを指定してもupdateが発生するため、ignore_changesを設定する
  # https://x.com/haru_256/status/1787591332682432556
  # https://github.com/hashicorp/terraform-provider-google/issues/12064
  # https://dev.classmethod.jp/articles/note-about-terraform-ignore-changes
  lifecycle {
    ignore_changes = [ node_config["reservation_affinity"] ]
  }
}
