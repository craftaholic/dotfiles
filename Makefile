SHELL := /bin/bash

.PHONY: default help setup copydotfiles build-docker

default: help

help:
	@echo "Welcome to my project - maintainer<Tommy Tran Duc Thang> - email<tommytran.dev@gmail.com>"
	@echo "Run make <task_name> to run predefined script"
	@echo ""
	@echo "For setting up the environment            make setup"
	@echo "For building the Docker image             make build-docker"
	@echo ""
	@echo "Available targets:"
	@echo "  help         - Show this help message"
	@echo "  setup        - Install the environment, setup env for macOS and Ubuntu"
	@echo "  copydotfiles - Create symlink to dotfiles (internal)"
	@echo "  build-docker - Build Docker image with GitHub token from GITHUB_TOKEN env"

setup:
	@echo "Checking for required tools..."
	@which stow &> /dev/null || { echo "stow not installed, please install stow first"; exit 1; }
	@which curl &> /dev/null || { echo "curl not installed, please install curl first"; exit 1; }
	@which zsh &> /dev/null || { echo "zsh not installed, please install zsh first"; exit 1; }
	@which gcc &> /dev/null || { echo "gcc not installed, please install gcc first"; exit 1; }
	@echo "----------------------------------------------------------------"
	@echo "This requires sudo permission to run"
	@echo "Are you okay with it? This only uses the role to create symblink"
	@echo "----------------------------------------------------------------"
	@sudo echo "Starting to setup system"
	@echo "----------------------------------------------------------------"
	@mkdir -p ~/.config
	@$(MAKE) copydotfiles
	@command -v mise &> /dev/null || { curl https://mise.run | MISE_INSTALL_PATH=/usr/local/bin/mise sh; }
	@mise install

copydotfiles:
	@for dir in */; do \
		dir=$${dir%/}; \
		if [ -d "$$dir" ] && [ "$$dir" != "node_modules" ] && [ "$$dir" != ".git" ]; then \
			echo "Creating symlinks for $$dir"; \
			stow -R --no-folding --target "$(HOME)" "$$dir" 2>/dev/null || stow -R --no-folding --target "$(HOME)" "$$dir"; \
		fi; \
	done

build-docker:
	@if [ -z "$$GITHUB_TOKEN" ]; then \
		echo "Error: GITHUB_TOKEN environment variable is not set"; \
		echo ""; \
		echo "Usage:"; \
		echo "  GITHUB_TOKEN=<your-github-token> make build-docker"; \
		echo "  export GITHUB_TOKEN=<your-github-token> && make build-docker"; \
		exit 1; \
	fi
	@echo "Building Docker image with GitHub token..."
	@echo "$$GITHUB_TOKEN" | DOCKER_BUILDKIT=1 docker build \
		--secret id=github_token,src=/dev/stdin \
		-t tommytran2804/devcontainer:latest \
		.
