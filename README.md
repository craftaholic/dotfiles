# Overview

This repository provides a framework structure for storing all of your working environment configurations in a declarative way, aiming to achieve a unified environment across different platforms and machines. The framework uses GNU Stow to manage symlinks from your home directory to the configuration files in this repository. This means that when you update the repository, all configuration files are automatically updated.

Additionally, this framework uses Devbox to install all required binaries and maintain consistent versions across platforms on all machines. Please read the instructions below on how to use it.

I provide both Taskfile and Makefile for all CLI scripting to ensure easy maintenance and readability. You can use either based on your preference.

This project requires executing a setup script to configure the local machine environment. Please follow the instructions below based on your operating system.

# Project Structure
```
.
├── LICENSE
├── Makefile                                # GNU Make build automation
├── README.md
├── Taskfile.yml                            # Task runner alternative to Make
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

To run this framework, you need either Taskfile or Make (most systems have Make pre-installed). The rest, including GNU Stow and Devbox, will be automatically installed during setup.

**Choose one:**
- **Make**: Pre-installed on most Unix systems (macOS, Linux)
- **Taskfile**: Modern task runner alternative - [Install Taskfile](https://taskfile.dev/installation/)

**Additional requirements:**
- **stow**: Install using brew, apt, or any package manager
- **zsh**

# Neovim Dotfiles

For details of my vim configuration, see: [Neovim Configuration](./nvim/.config/nvim/README.md)

# Installation

To install the environment, run one of the following commands:

**Using Make:**
```bash
make setup
```

**Using Taskfile:**
```bash
task setup
```

>**NOTE**: This command will only succeed if the target configuration files do not exist beforehand.
So you will need to backup your existing configuration files firsts.

This command will:
- Install GNU Stow if it's not already installed.
- Create ~/.config directory if it doesn't exist.
- Create symlinks from your home directory to the configuration files in this repository using GNU Stow.
- Install Devbox if it's not already installed.
- Install all required binaries (e.g., git, zsh) using the devbox.json configuration located in packages/.local/share/devbox/global/default/.

# Available Commands

Both `Makefile` and `Taskfile.yml` provide the same tasks to manage your environment:

| Command | Make | Taskfile |
|---------|------|----------|
| **Default/Help** | `make` or `make help` | `task` or `task help` |
| **Setup** | `make setup` | `task setup` |

All commands will:
- Display help information (default/help)
- Install the environment and setup for macOS and Ubuntu (setup)

# Devbox Integration

The devbox configuration is managed through the devbox.json file located at:
```
packages/.local/share/devbox/global/default/devbox.json
```

This file defines all the packages that will be installed and maintained by Devbox. To add, remove, or update packages, edit this file and run `devbox global install` or use the setup command:
```bash
make setup  # or: task setup
```

# For WSL Specifically

For Neovim to work properly with the WSL clipboard, you should install `win32yank` using PowerShell:
```
choco install win32yank
```

