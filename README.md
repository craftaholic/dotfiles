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
├── aerospace                   # macOS window manager configuration
├── nvim                        # Neovim configuration
├── tmux                        # Tmux configuration
├── wezterm                     # Wezterm terminal configuration
├── zsh                         # Zsh shell configuration
└── devbox.json                 # Maintain all your binaries in declarative way
```

# Prerequisites

To run this framework, you only need to have Taskfile (similar to Makefile). The rest, including GNU Stow and Devbox, will be automatically installed during setup.

- **Taskfile**: To install Taskfile, follow this guide: [Link to install Taskfile](https://taskfile.dev/installation/)

# Neovim Dotfiles

For details of my vim configuration, see: [Neovim Configuration](./nvim/README.md)

# Installation

To install the environment, run the following command:
```
task setup
```

>**NOTE**: This command will only succeed if the target configuration files do not exist beforehand.
So you will need to backup your existing configuration files firsts.

To force overwrite (In case this framework is the main way you maintain your environment)
```
task setup -- force
```
> **IMPORTANT**: When running `task setup -- force`, it will overwrite all of your environment configuration files if exists. Please run it with care and backup your configuration first. To check which files will be overwritten, check taskfile.yml

This command will:
- Install GNU Stow if it's not already installed.
- Create ~/.config directory if it doesn't exist.
- Create symlinks from your home directory to the configuration files in this repository using GNU Stow.
- Install Devbox if it's not already installed.
- Install all required binaries (e.g., git, zsh).

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
  Or
  ```
  task setup -- force
  ```

# For WSL Specifically

For Neovim to work properly with the WSL clipboard, you should install `win32yank` using PowerShell:
```
choco install win32yank
```

