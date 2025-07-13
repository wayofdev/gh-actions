# 🤖 Renovate Guidelines for wayofdev Projects

> **Version**: 1.0
> **Last Updated**: January 2025
> **Organization**: [wayofdev](https://github.com/wayofdev)

## 📋 Table of Contents

- [🎯 Overview](#-overview)
- [🚀 Quick Start](#-quick-start)
- [⚙️ Base Configuration Template](#️-base-configuration-template)
- [🔧 Technology-Specific Configurations](#-technology-specific-configurations)
- [🏷️ Package Rules & Best Practices](#️-package-rules--best-practices)
- [🔒 Security & Compliance](#-security--compliance)
- [🛠️ Integration Patterns](#️-integration-patterns)
- [✅ Validation & Testing](#-validation--testing)
- [🐛 Troubleshooting](#-troubleshooting)
- [🤖 AI Agent Instructions](#-ai-agent-instructions)

---

## 🎯 Overview

This guide provides standardized Renovate configuration patterns for wayofdev projects, ensuring consistent dependency management across our diverse tech stack including PHP (Laravel, Spiral), NextJS, Docker, Ansible, Terraform, Go, and Python projects.

### Core Principles

- **🔒 Security First**: Always pin versions and use digest hashing for container images
- **⚡ Automation**: Auto-merge safe updates (minor/patch), manual approval for breaking changes
- **📊 Visibility**: Use dependency dashboard and proper labeling
- **🎯 Consistency**: Standardized patterns across all repositories
- **🛡️ Safety**: Comprehensive testing before applying updates

---

## 🚀 Quick Start

### 1. Copy Base Configuration

```bash
# Copy this guidelines file to your project
cp renovate-guidelines.md .cursor/
# or
curl -o .cursor/renovate-guidelines.md https://raw.githubusercontent.com/wayofdev/gh-actions/master/.cursor/renovate-guidelines.md
```

### 2. Create renovate.json5

Choose the appropriate base configuration from the [Technology-Specific Configurations](#-technology-specific-configurations) section.

### 3. Setup Repository Labels

Create these labels in your GitHub repository:

```text
dependencies        - #A141FA (purple)
github-actions      - #0366d6 (blue)
pre-commit          - #f1c232 (yellow)
major-update        - #d73a49 (red)
auto-merge          - #28a745 (green)
self-update         - #6f42c1 (purple)
docker              - #2188ff (blue)
composer            - #f29400 (orange)
npm                 - #cb0000 (red)
```

### 4. Configure Automation

- Ensure `@way-finder-bot` has appropriate permissions
- Set up auto-approval workflows if needed
- Configure branch protection rules

---

## ⚙️ Base Configuration Template

```json5
{
    "$schema": "https://docs.renovatebot.com/renovate-schema.json",
    "extends": [
        "config:recommended",
        "group:monorepos",
        "group:recommended",
        "workarounds:all"
    ],
    "prHourlyLimit": 0,
    "automerge": true,
    "platformAutomerge": true,
    "dependencyDashboard": true,
    "dependencyDashboardTitle": "🤖 Dependency Dashboard",
    "commitMessagePrefix": "chore(deps):",
    "commitMessageAction": "update",
    "commitMessageTopic": "{{depName}}",
    "commitMessageExtra": "to {{newVersion}}",
    "labels": ["dependencies"],
    "assignees": ["lotyp"],
    "timezone": "Europe/Warsaw",
    "schedule": ["before 6am on Saturday"],
    "lockFileMaintenance": {
        "enabled": true,
        "automerge": true,
        "schedule": ["before 6am on Saturday"]
    },
    "packageRules": [
        {
            "description": "Separate major updates",
            "matchUpdateTypes": ["major"],
            "groupName": "major dependencies",
            "automerge": false,
            "addLabels": ["major-update"],
            "dependencyDashboardApproval": true
        },
        {
            "description": "Auto-merge minor and patch updates",
            "matchUpdateTypes": ["minor", "patch"],
            "automerge": true,
            "addLabels": ["auto-merge"]
        }
    ]
}
```

---

## 🔧 Technology-Specific Configurations

### PHP Projects (Laravel, Spiral Framework)

**Package Manager**: Composer

```json5
{
    "extends": ["@wayofdev:base"],
    "packageRules": [
        {
            "description": "Group PHP dependencies",
            "matchManagers": ["composer"],
            "groupName": "PHP dependencies",
            "addLabels": ["composer"],
            "commitMessageTopic": "PHP dependencies"
        },
        {
            "description": "Pin Laravel framework versions",
            "matchPackageNames": ["laravel/framework", "laravel/laravel"],
            "automerge": false,
            "dependencyDashboardApproval": true
        },
        {
            "description": "Auto-merge dev dependencies",
            "matchManagers": ["composer"],
            "matchDepTypes": ["require-dev"],
            "automerge": true,
            "groupName": "PHP dev dependencies"
        }
    ]
}
```

### NextJS Projects

**Package Manager**: pnpm

```json5
{
    "extends": ["@wayofdev:base"],
    "packageRules": [
        {
            "description": "Group pnpm dependencies",
            "matchManagers": ["npm"],
            "groupName": "npm dependencies",
            "addLabels": ["npm"],
            "commitMessageTopic": "npm dependencies"
        },
        {
            "description": "Pin Next.js major versions",
            "matchPackageNames": ["next"],
            "matchUpdateTypes": ["major"],
            "automerge": false,
            "dependencyDashboardApproval": true
        },
        {
            "description": "Group React ecosystem",
            "matchPackageNames": ["react", "react-dom", "@types/react", "@types/react-dom"],
            "groupName": "React ecosystem",
            "automerge": false
        }
    ]
}
```

### Python Projects

**Package Manager**: uv

```json5
{
    "extends": ["@wayofdev:base"],
    "packageRules": [
        {
            "description": "Group Python dependencies",
            "matchManagers": ["pip_requirements", "pip_setup", "pipenv", "poetry"],
            "groupName": "Python dependencies",
            "addLabels": ["python"],
            "commitMessageTopic": "Python dependencies"
        },
        {
            "description": "Pin Python major versions carefully",
            "matchManagers": ["pip_requirements", "pip_setup", "pipenv", "poetry"],
            "matchUpdateTypes": ["major"],
            "automerge": false,
            "dependencyDashboardApproval": true
        }
    ]
}
```

### Docker Projects

```json5
{
    "extends": ["@wayofdev:base"],
    "packageRules": [
        {
            "description": "Group Docker dependencies",
            "matchManagers": ["docker-compose", "dockerfile"],
            "groupName": "Docker dependencies",
            "addLabels": ["docker"],
            "commitMessageTopic": "Docker dependencies",
            "pinDigests": true
        },
        {
            "description": "Pin base image versions",
            "matchManagers": ["dockerfile"],
            "matchPackageNames": ["node", "php", "python", "alpine"],
            "automerge": false,
            "dependencyDashboardApproval": true
        }
    ]
}
```

### Infrastructure (Ansible, Terraform)

```json5
{
    "extends": ["@wayofdev:base"],
    "packageRules": [
        {
            "description": "Group Terraform dependencies",
            "matchManagers": ["terraform"],
            "groupName": "Terraform dependencies",
            "addLabels": ["terraform"],
            "automerge": false,
            "dependencyDashboardApproval": true
        },
        {
            "description": "Group Ansible dependencies",
            "matchManagers": ["ansible"],
            "groupName": "Ansible dependencies",
            "addLabels": ["ansible"],
            "automerge": false
        }
    ]
}
```

---

## 🏷️ Package Rules & Best Practices

### Universal Package Rules

```json5
"packageRules": [
    {
        "description": "Group GitHub Actions updates",
        "matchManagers": ["github-actions"],
        "groupName": "GitHub Actions",
        "automerge": true,
        "addLabels": ["github-actions"],
        "commitMessageTopic": "GitHub Actions",
        "pinDigests": true
    },
    {
        "description": "Group pre-commit hook updates",
        "matchManagers": ["pre-commit"],
        "groupName": "pre-commit hooks",
        "automerge": true,
        "addLabels": ["pre-commit"],
        "commitMessageTopic": "pre-commit hooks"
    },
    {
        "description": "Group wayofdev self-references",
        "matchPackageNames": ["wayofdev/*"],
        "groupName": "wayofdev self-updates",
        "automerge": false,
        "addLabels": ["self-update"],
        "commitMessageTopic": "self-reference"
    },
    {
        "description": "Security updates get priority",
        "matchDepTypes": ["security"],
        "prPriority": 10,
        "automerge": true,
        "addLabels": ["security"]
    }
]
```

### Scheduling Patterns

```json5
{
    "schedule": ["before 6am on Saturday"],
    "timezone": "Europe/Warsaw"
}
```

**Alternative schedules:**

- `["before 6am on Monday"]` - Start of work week
- `["after 10pm on Friday"]` - End of work week
- `["every weekend"]` - Flexible weekend timing
- `["before 4am on the first day of the month"]` - Monthly updates

---

## 🔒 Security & Compliance

### Required Security Practices

```json5
{
    "vulnerabilityAlerts": {
        "enabled": true
    },
    "osvVulnerabilityAlerts": true,
    "suppressNotifications": ["prIgnoreNotification"],
    "packageRules": [
        {
            "description": "Pin GitHub Action digests for security",
            "matchManagers": ["github-actions"],
            "pinDigests": true
        },
        {
            "description": "Pin Docker image digests",
            "matchManagers": ["docker-compose", "dockerfile"],
            "pinDigests": true
        },
        {
            "description": "Auto-merge security patches",
            "matchDepTypes": ["security"],
            "automerge": true,
            "prPriority": 10
        }
    ]
}
```

### Compliance Best Practices

1. **Version Pinning**: Always pin to specific versions, not ranges
2. **Digest Hashing**: Use SHA digests for container images
3. **Vulnerability Scanning**: Enable OSV and GitHub vulnerability alerts
4. **Audit Trails**: Maintain detailed commit messages and labels
5. **Review Process**: Require manual approval for major updates
6. **License Compliance**: Monitor license changes in dependencies

### SBOM (Software Bill of Materials)

Consider integrating SBOM generation tools:

- GitHub's dependency graph
- Syft for container images
- CycloneDX for comprehensive SBOM

---

## 🛠️ Integration Patterns

### Makefile Integration

Add to your project's `Makefile`:

```makefile
# Renovate validation and testing
RENOVATE_RUNNER ?= $(DOCKER) run --rm $$(tty -s && echo "-it" || echo) \
 -v $(shell pwd):/usr/src/app \
 --workdir /usr/src/app \
 renovate/renovate:latest

lint-renovate: ## Validate renovate configuration
 @echo "${GREEN}🤖 Validating renovate.json5 configuration...${RST}"
 @$(RENOVATE_RUNNER) renovate-config-validator renovate.json5 | tee -a $(MAKE_LOGFILE)
.PHONY: lint-renovate

renovate-dry-run: ## Run renovate in dry-run mode (requires GITHUB_TOKEN)
 @echo "${GREEN}🤖 Running renovate in dry-run mode...${RST}"
 @if [ -z "$(GITHUB_TOKEN)" ]; then \
  echo "${RED}❌ Error: GITHUB_TOKEN environment variable is required${RST}"; \
  echo "${YELLOW}💡 Set it with: export GITHUB_TOKEN=your_token_here${RST}"; \
  exit 1; \
 fi
 @$(RENOVATE_RUNNER) \
  -e GITHUB_TOKEN="$(GITHUB_TOKEN)" \
  -e LOG_LEVEL=info \
  renovate --dry-run --print-config | tee -a $(MAKE_LOGFILE)
.PHONY: renovate-dry-run

# Include in main lint target
lint: lint-yaml lint-actions lint-md lint-renovate
```

### GitHub Actions Workflow

Optional CI integration for Renovate validation:

```yaml
name: 🤖 Validate Renovate Config

on:
  push:
    paths: ['renovate.json5', '.github/renovate.json5']
  pull_request:
    paths: ['renovate.json5', '.github/renovate.json5']

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: 🤖 Validate Renovate configuration
        run: |
          docker run --rm -v $(pwd):/usr/src/app \
            --workdir /usr/src/app \
            renovate/renovate:latest \
            renovate-config-validator renovate.json5
```

### Pre-commit Integration

Add to `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: local
    hooks:
      - id: renovate-validate
        name: Validate Renovate config
        entry: docker run --rm -v .:/usr/src/app --workdir /usr/src/app renovate/renovate:latest renovate-config-validator
        args: [renovate.json5]
        language: system
        files: ^renovate\.json5$
        pass_filenames: false
```

---

## ✅ Validation & Testing

### Local Validation

```bash
# Validate configuration
make lint-renovate

# Test what Renovate would do (requires GITHUB_TOKEN)
export GITHUB_TOKEN=your_token_here
make renovate-dry-run

# Validate JSON5 syntax
python3 -c "import json5; json5.load(open('renovate.json5'))"

# Use Docker for validation (recommended)
docker run --rm -v $(pwd):/usr/src/app \
  --workdir /usr/src/app \
  renovate/renovate:latest \
  renovate-config-validator renovate.json5
```

### Testing Checklist

- [ ] ✅ Configuration validates successfully
- [ ] 🏷️ All required labels exist in repository
- [ ] 🔐 Bot permissions are configured
- [ ] 📋 Dependency dashboard is enabled
- [ ] 🧪 Dry-run shows expected behavior
- [ ] 📝 Commit message format is correct
- [ ] 🔄 Automerge rules work as expected
- [ ] 🚨 Security alerts are enabled

---

## 🐛 Troubleshooting

### Common Issues

#### 1. **Configuration Validation Fails**

```bash
# Check JSON5 syntax
python3 -c "import json5; json5.load(open('renovate.json5'))"

# Use Docker validation (recommended)
docker run --rm -v $(pwd):/usr/src/app \
  --workdir /usr/src/app \
  renovate/renovate:latest \
  renovate-config-validator renovate.json5
```

#### 2. **Bot Not Creating PRs**

- Check repository access permissions
- Verify GitHub token scope (`repo` required)
- Ensure `platform` is set correctly
- Check `includePaths` and `ignorePaths` settings

#### 3. **Automerge Not Working**

- Verify branch protection rules allow automerge
- Check `platformAutomerge` setting
- Ensure bot has write permissions
- Review `packageRules` conditions

#### 4. **Too Many PRs Created**

```json5
{
    "prConcurrentLimit": 5,
    "prHourlyLimit": 2
}
```

#### 5. **Major Updates Not Approved**

- Check `dependencyDashboardApproval` setting
- Verify dependency dashboard is enabled
- Review `matchUpdateTypes` configuration

### Debug Configuration

Add for troubleshooting:

```json5
{
    "logLevel": "debug",
    "printConfig": true,
    "dryRun": true
}
```

### Support Resources

- [Renovate Documentation](https://docs.renovatebot.com/)
- [wayofdev GitHub Discussions](https://github.com/orgs/wayofdev/discussions)
- [Renovate Discord Community](https://discord.gg/renovate)

---

## 🤖 AI Agent Instructions

### For Claude/Cursor Agents

When working with Renovate configurations in wayofdev projects:

#### 1. **Analysis Phase**

- Always start by identifying the project's tech stack
- Check existing `renovate.json5` and `package.json`/`composer.json`/`requirements.txt`
- Review current dependency managers in use

#### 2. **Configuration Selection**

- Use the appropriate technology-specific template from this guide
- Always include the base security and compliance rules
- Customize scheduling based on project requirements

#### 3. **Validation Requirements**

- Always validate configuration using Docker method
- Test with dry-run when possible
- Verify JSON5 syntax before committing

#### 4. **Integration Steps**

1. Create/update `renovate.json5` with appropriate config
2. Add Makefile integration commands
3. Ensure required labels exist
4. Test configuration validation
5. Document any project-specific customizations

#### 5. **Best Practices to Follow**

- Pin versions for security
- Group related updates
- Use descriptive commit messages
- Enable dependency dashboard
- Set appropriate automerge rules
- Include vulnerability scanning

#### 6. **Common Customizations**

- Adjust scheduling based on team preferences
- Modify automerge rules for project stability requirements
- Add technology-specific package rules
- Configure grouping for monorepos
- Set up custom regex managers for non-standard dependencies

#### 7. **Error Handling**

- Always provide validation commands
- Include troubleshooting steps in explanations
- Offer alternative configurations if initial setup fails
- Document any limitations or known issues

### Template Variables for Customization

When creating project-specific configurations, replace these variables:

- `{{PROJECT_NAME}}` - Current project name
- `{{TECH_STACK}}` - Primary technology (php, nodejs, python, etc.)
- `{{PACKAGE_MANAGER}}` - Specific package manager (composer, pnpm, uv, etc.)
- `{{TIMEZONE}}` - Project team timezone
- `{{ASSIGNEE}}` - Default assignee for PRs
- `{{SCHEDULE}}` - Preferred update schedule

---

## 📚 Additional Resources

- [Renovate Configuration Options](https://docs.renovatebot.com/configuration-options/)
- [wayofdev Standards](https://github.com/wayofdev/.github)
- [Security Best Practices](https://docs.renovatebot.com/security/)
- [Package Rules Examples](https://docs.renovatebot.com/package-rules/)

---

**💡 Remember**: This is a living document. Update it as our practices evolve and new technologies are adopted in wayofdev projects.

**🤝 Contributing**: Submit improvements via PR to the [gh-actions repository](https://github.com/wayofdev/gh-actions).
