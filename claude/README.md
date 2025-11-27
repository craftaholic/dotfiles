# Claude Code Configuration

This directory contains Claude Code configurations, including agents, skills, and plugins.

## Directory Structure

```
claude/
├── .claude/                 # Maps to ~/.claude in home directory
│   ├── agents/              # Claude Code agent definitions
│   ├── skills/              # Claude Code skill modules
│   └── commands/            # Claude Code custom commands
└── .claude-plugin/          # Maps to ~/.claude-plugin in home directory
    └── marketplace.json     # Claude Code plugin marketplace configuration
```

## Agents & Skills

This collection includes specialized Claude Code agents and skills for software/platform engineering tasks, organized by domain expertise:

- **Cloud Architecture**: Multi-cloud architecture patterns (AWS, Azure, GCP)
- **Infrastructure Automation**: Terraform, OpenTofu, Pulumi, IaC best practices
- **Kubernetes & Containers**: K8s, GitOps, service mesh, container patterns
- **Observability**: Metrics, logging, tracing, SLOs
- **Software Architecture**: Clean Architecture, DDD, Hexagonal, Microservices
- **Backend Development**: Golang, TypeScript, Python patterns
- **Frontend Development**: React, Next.js, state management
- **DevOps Workflows**: CI/CD, deployment strategies, automation
- **Security & Compliance**: Secure coding, auth patterns, compliance
- **Technical Leadership**: Documentation, decisions, code review

## Installation

These configurations are automatically symlinked to the appropriate locations through GNU Stow when you run:

```bash
# From the dotfiles directory
stow claude
```

## Updating

To update the configurations:

1. Make changes directly to the files in this directory
2. Run `stow -R claude` to refresh the symlinks if needed

## Manual Activation

To manually activate Claude Code plugins without stow:

```bash
cp -r ~/.claude-plugin/marketplace.json ~/.claude-plugin/
cp -r ~/.claude/agents/* ~/.claude/agents/
cp -r ~/.claude/skills/* ~/.claude/skills/
cp -r ~/.claude/commands/* ~/.claude/commands/
```