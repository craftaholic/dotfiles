# Overview

This repository provides a framework structure for storing all of your working environment configurations in a declarative way, aiming to achieve a unified environment across different platforms and machines. The framework uses GNU Stow to manage symlinks from your home directory to the configuration files in this repository. This means that when you update the repository, all configuration files are automatically updated.

Additionally, this framework uses Devbox to install all required binaries and maintain consistent versions across platforms on all machines. Please read the instructions below on how to use it.

I use Taskfile for all CLI scripting to ensure easy maintenance and readability.

This project requires executing a setup script to configure the local machine environment. Please follow the instructions below based on your operating system.

# Project Structure
```
.
├── LICENSE
├── README.md
├── Taskfile.yml
├── aerospace                               # macOS window manager configuration
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

To run this framework, you only need to have Taskfile (similar to Makefile). The rest, including GNU Stow and Devbox, will be automatically installed during setup.

- **Taskfile**: To install Taskfile, follow this guide: [Link to install Taskfile](https://taskfile.dev/installation/)
- **stow**: You will need to install stow, to install use brew, apt, or any package manager

# Neovim Dotfiles

For details of my vim configuration, see: [Neovim Configuration](./nvim/README.md)

# Installation

To install the environment, run the following command:
```
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

# Taskfile Commands

The `Taskfile.yml` provides several tasks to manage your environment:

- **Default Task**: Displays help information.
  ```
  task
  ```

- **Help**: Provides a welcome message and lists available tasks.
  ```
  task help
  ```

- **Setup**: Installs the environment and sets up the environment for macOS and Ubuntu.
  ```
  task setup
  ```

# Devbox Integration

The devbox configuration is managed through the devbox.json file located at:
```
packages/.local/share/devbox/global/default/devbox.json
```

This file defines all the packages that will be installed and maintained by Devbox. To add, remove, or update packages, edit this file and run `devbox global install` or use the setup task:
```
task setup
```

# For WSL Specifically

For Neovim to work properly with the WSL clipboard, you should install `win32yank` using PowerShell:
```
choco install win32yank
```

