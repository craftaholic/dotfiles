DEVBOX_DIR_PATH := $(HOME)/.local/share/devbox/global/default

.PHONY: default help setup copydotfiles

default: help

help:
	@echo "Welcome to my project - maintainer<Tommy Tran Duc Thang> - email<tommytran.dev@gmail.com>"
	@echo "Run make <task_name> to run predefined script"
	@echo ""
	@echo "For setting up the environment            make setup"
	@echo ""
	@echo "Available targets:"
	@echo "  help         - Show this help message"
	@echo "  setup        - Install the environment, setup env for macOS and Ubuntu"
	@echo "  copydotfiles - Create symlink to dotfiles (internal)"

setup:
	@echo "----------------------------------------------------------------"
	@echo "This requires sudo permission to run"
	@echo "Are you okay with it? This only uses the role to create symblink"
	@echo "----------------------------------------------------------------"
	@sudo echo "Starting to setup system"
	@echo "----------------------------------------------------------------"
	@which stow &> /dev/null || { echo "stow not installed, please install stow first"; exit 1; }
	@echo "Creating ~/.config and ~/.notes directory if it doesn't exist..."
	@mkdir -p ~/.config
	@mkdir -p ~/.notes
	@$(MAKE) copydotfiles
	@command -v devbox &> /dev/null || { curl -fsSL https://get.jetify.com/devbox | bash; }
	@devbox global install

copydotfiles:
	@for dir in */; do \
		dir=$${dir%/}; \
		if [ -d "$$dir" ] && [ "$$dir" != "node_modules" ] && [ "$$dir" != ".git" ]; then \
			echo "Creating symlinks for $$dir"; \
			stow -R --no-folding --target "$(HOME)" "$$dir" 2>/dev/null || stow -R --no-folding --target "$(HOME)" "$$dir"; \
		fi; \
	done
