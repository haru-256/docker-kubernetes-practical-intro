# moved {
#   from = module.tfstate_bucket.google_project_service.services
#   to   = module.required_project_services.google_project_service.api_services["storage.googleapis.com"]
# }
# moved {
#   from = module.gke.google_project_service.services["storage.googleapis.com"]
#   to   = module.required_project_services.google_project_service.api_services["storage.googleapis.com"]
# }
# moved {
#   from = module.gke.google_project_service.services["compute.googleapis.com"]
#   to   = module.required_project_services.google_project_service.api_services["compute.googleapis.com"]
# }
