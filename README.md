# Overview

This repository provides a framework structure for storing all of your working environment configurations in a declarative way, aiming to achieve a unified environment across different platforms and machines. The framework uses GNU Stow to manage symlinks from your home directory to the configuration files in this repository. This means that when you update the repository, all configuration files are automatically updated.

Additionally, this framework uses Devbox to install all required binaries and maintain consistent versions across platforms on all machines. Please read the instructions below on how to use it.

This project can be installed either directly on your local machine or used through a Docker container for a fully isolated development environment.

# Project Structure
```
.
├── LICENSE
├── Makefile                                # GNU Make build automation
├── README.md
├── aerospace                               # macOS window manager configuration
├── claude                                  # Claude AI configuration and context
├── nvim                                    # Neovim configuration
├── packages                                # Contains the devbox configuration
│   └── .local
│       └── share
│           └── devbox
│               └── global
│                   └── default
│                       └── devbox.json     # Maintain all your binaries in declarative way
├── tmux                                    # Tmux configuration
├── wezterm                                 # Wezterm terminal configuration
└── zsh                                     # Zsh shell configuration
```

# Prerequisites

## Local Installation

To run this framework locally, you need Make (pre-installed on most systems). The rest, including GNU Stow and Devbox, will be automatically installed during setup.

**Requirements:**
- **Make**: Pre-installed on most Unix systems (macOS, Linux)
- **stow**: Install using brew, apt, or any package manager
- **zsh**

## Docker Installation

Alternatively, you can use the pre-configured Docker container which includes all dependencies and tools pre-installed:

**Requirements:**
- **Docker**: [Install Docker](https://docs.docker.com/get-docker/)

# Neovim Dotfiles

For details of my vim configuration, see: [Neovim Configuration](./nvim/.config/nvim/README.md)

# Installation

## Option 1: Local Installation

To install the environment locally, run the following command:

```bash
make setup
```

>**NOTE**: This command will only succeed if the target configuration files do not exist beforehand.
So you will need to backup your existing configuration files first.

This command will:
- Install GNU Stow if it's not already installed.
- Create ~/.config directory if it doesn't exist.
- Create symlinks from your home directory to the configuration files in this repository using GNU Stow.
- Install Devbox if it's not already installed.
- Install all required binaries (e.g., git, zsh) using the devbox.json configuration located in packages/.local/share/devbox/global/default/.

## Option 2: Docker Container

Use the pre-configured development container with all tools and configurations included:

```bash
# Pull the latest image
docker pull ghcr.io/craftaholic/devcontainer:latest

# Run the container with your workspace mounted
docker run -it -v $(pwd):/workspace ghcr.io/craftaholic/devcontainer:latest

# Or run with additional options
docker run -it \
  -v $(pwd):/workspace \
  -v ~/.ssh:/root/.ssh:ro \
  -v ~/.gitconfig:/root/.gitconfig:ro \
  ghcr.io/craftaholic/devcontainer:latest
```

The Docker container includes:
- All configuration files pre-installed and configured
- Devbox with all required binaries
- Pre-configured development environment (Neovim, Tmux, Zsh, etc.)
- No setup required - ready to use immediately

# Available Commands

The `Makefile` provides tasks to manage your environment:

| Command | Description |
|---------|-------------|
| `make` or `make help` | Display help information |
| `make setup` | Install the environment and setup for macOS and Ubuntu |

# Devbox Integration

The devbox configuration is managed through the devbox.json file located at:
```
packages/.local/share/devbox/global/default/devbox.json
```

This file defines all the packages that will be installed and maintained by Devbox. To add, remove, or update packages, edit this file and run `devbox global install` or use the setup command:
```bash
make setup
```

# For WSL Specifically

For Neovim to work properly with the WSL clipboard, you should install `win32yank` using PowerShell:
```
choco install win32yank
```

