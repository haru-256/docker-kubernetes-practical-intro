.PHONY: plan apply help

.DEFAULT_GOAL := help

format: # format terraform
	$(MAKE) -C ../../ format

lint: # lint terraform
	$(MAKE) -C ../../ lint

echo:
	$(MAKE) -C ../../ echo

plan: # terraform plan
	terraform plan

apply: # terraform apply
	terraform apply

help: # Show help for each of the Makefile recipes.
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done
