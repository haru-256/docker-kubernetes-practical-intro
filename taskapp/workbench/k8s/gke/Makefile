.PHONY: help connect-cluster run-debug-container

.DEFAULT_GOAL := help

connect-cluster: # Connect to GKE
	gcloud container clusters get-credentials sandbox --region us-central1 --project haru256-sandbox-20240502

run-debug-container: # Run a debug container in the GKE cluster
	kubectl run -n taskapp -i --rm --tty debug --image=ghcr.io/gihyodocker/debug:v0.1.0 --restart=Never -- bash

help: # Show help for each of the Makefile recipes.
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done
