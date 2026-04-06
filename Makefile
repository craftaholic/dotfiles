DEVBOX_DIR_PATH := $(HOME)/.local/share/devbox/global/default

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
	@echo "----------------------------------------------------------------"
	@echo "This requires sudo permission to run"
	@echo "Are you okay with it? This only uses the role to create symblink"
	@echo "----------------------------------------------------------------"
	@sudo echo "Starting to setup system"
	@echo "----------------------------------------------------------------"
	@which stow &> /dev/null || { echo "stow not installed, please install stow first"; exit 1; }
	@echo "Initializing git submodules..."
	@git submodule update --init --recursive
	@echo "Creating ~/.config and ~/.notes directory if it doesn't exist..."
	@mkdir -p ~/.config
	@mkdir -p ~/.notes
	@$(MAKE) copydotfiles
	@command -v mise &> /dev/null || { curl https://mise.run | sh; }
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
		echo "  GITHUB_TOKEN=ghp_yourtoken make build-docker"; \
		echo "  export GITHUB_TOKEN=ghp_yourtoken && make build-docker"; \
		exit 1; \
	fi
	@echo "Building Docker image with GitHub token..."
	@echo "$$GITHUB_TOKEN" | DOCKER_BUILDKIT=1 docker build \
		--secret id=github_token,src=/dev/stdin \
		-t tommytran2804/devcontainer:latest \
		.
