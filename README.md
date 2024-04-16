<br>

<div align="center">
<img width="456" src="https://raw.githubusercontent.com/wayofdev/gh-actions/master/assets/logo.gh-light-mode-only.png#gh-light-mode-only" alt="WayOfDev Logo for light theme">
<img width="456" src="https://raw.githubusercontent.com/wayofdev/gh-actions/master/assets/logo.gh-dark-mode-only.png#gh-dark-mode-only" alt="WayOfDev Logo for dark theme">
</div>

<br>

<br>

<div align="center">
<a href="https://github.com/wayofdev/gh-actions/actions" target="_blank"><img alt="Build Status" src="https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fwayofdev%2Fgh-actions%2Fbadge&style=flat-square"/></a>
<a href="LICENSE.md"><img src="https://img.shields.io/github/license/wayofdev/gh-actions.svg?style=flat-square&color=blue" alt="Software License"/></a>
<a href="" target="_blank"><img alt="Commits since latest release" src="https://img.shields.io/github/commits-since/wayofdev/gh-actions/latest?style=flat-square"></a>
<a href="https://discord.gg/CE3TcCC5vr" target="_blank"><img alt="Codecov" src="https://img.shields.io/discord/1228506758562058391?style=flat-square&logo=discord&labelColor=7289d9&logoColor=white&color=39456d"></a>
<a href="https://twitter.com/intent/follow?screen_name=wayofdev" target="_blank"><img alt="Follow on Twitter" src="https://img.shields.io/twitter/follow/wayofdev.svg?style=flat-square&logo=x&color=6e7781"></a>
</div>

<br>

# Shared GitHub Actions

This repository is a collection of [reusable workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows) and [composite actions](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action), specifically designed for use in [wayofdev](https://github.com/wayofdev) projects.

These tools encapsulate common and repetitive tasks, allowing for easy integration into multiple projects. This approach not only reduces the need to rewrite code but also ensures standardized operations across all Wayofdev repositories.

<br>

## 📋 Table of Contents

- [Getting Started](#-getting-started)
- [Composite Actions](#-composite-actions)
- [Workflows](#-workflows)
  - [Auto Label and Release Management](#-auto-label-and-release-management)
  - [Docker Workflows](#-docker-workflows)
  - [Code Architecture](#-code-architecture)
  - [Static Analysis](#-static-analysis)
- [License](#-license)
- [Security Policy](#-security-policy)
- [Contributing](#-want-to-contribute)
- [Social Links](#-social-links)
- [Author Information](#-author-information)
- [Useful Resources](#-useful-resources)

<br>

## 🚀 Getting Started

To use these workflows and actions, reference them directly from your project's workflows. Detailed instructions for each are provided below.

<br>

## ⚡️ Composite Actions

Composite Actions are a powerful feature of GitHub Actions that allow you to create reusable actions using a combination of other actions, shell commands, or both.

This enables you to encapsulate a sequence of steps into a single action, making your workflows more modular, easier to maintain, and reducing duplication across your projects.

Composite Actions can accept inputs and use outputs, making them highly flexible and adaptable to various use cases.

Check each action's README file for detailed instructions on how to use it.

| **Action**                                                                                 | **Description**                                                                                    |
|--------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------|
| [`actions/composer/get-cache-directory`](./actions/composer/get-cache-directory/README.md) | Gets the Composer cache directory path and exports it as env variable.                             |
| [`actions/composer/get-root-version`](./actions/composer/get-root-version/README.md)       | determines the Composer root version based on the specified branch and exports it as env variable. |
| [`actions/composer/install`](./actions/composer/install/README.md)                         | Installs dependencies with Composer based on the specified dependency level.                       |
| [`actions/phive/install`](./actions/phive/install/README.md)                               | Install dependencies with [Phive](https://phar.io).                                                |
| [`actions/playwright/install`](./actions/playwright/install/README.md)                     | Installs [Playwright](https://playwright.dev/) along with its dependencies.                        |
| [`actions/pnpm/install`](./actions/pnpm/install/README.md)                                 | Installs mono-repository dependencies using [PNPM](https://pnpm.io/).                              |

<br>

## ⚡️ Workflows

Read more about [reusing workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows).

### → Auto Label and Release Management

#### `apply-labels.yml:`

Automatically applies labels to pull requests based on modified paths.

This workflow triages pull requests and applies labels based on the paths that are modified in the pull request. This can help to categorize your pull requests and make it easier to identify the type of changes included.

To use this workflow, set up a `.github/labeler.yml` file with your configuration in your project. For more information on how to configure the labeler, see: https://github.com/actions/labeler/blob/master/README.md

Here is an example of how to use this workflow:

<details>
<summary><code>.github/workflows/apply-labels.yml</code></summary>

```yaml
---

on:
  pull_request:

name: 🏷️ Add labels

jobs:
  label:
    uses: wayofdev/gh-actions/.github/workflows/apply-labels.yml@master
    with:
      os: ubuntu-latest
    secrets:
      token: ${{ secrets.GITHUB_TOKEN }}

...
```

</details>
<details>
<summary><code>.github/labeler.yml</code></summary>

```yaml
---

"type: bug":
    - head-branch: ['^bug', '^fix', 'bug', 'fix']

"type: enhancement":
    - head-branch: ['^feature', '^feat', 'feature']

"type: documentation":
    - changed-files:
          - any-glob-to-any-file: ['assets/**/*', '.github/*', './*.md']

"type: maintenance":
    - changed-files:
          - any-glob-to-any-file: ['tests/**/*', '.github/workflows/*']

...
```
</details>


<br>

#### `auto-merge-release.yml:`

This workflow automatically merges releases. This workflow utilizes [peter-evans/enable-pull-request-automerge](https://github.com/peter-evans/enable-pull-request-automerge) to auto-merge releases that are created by [googleapis/release-please](https://github.com/googleapis/release-please).

Here is an example of how to use this workflow:

<details>
<summary><code>.github/workflows/auto-merge-release.yml</code></summary>

```yaml
---

on:  # yamllint disable-line rule:truthy
  pull_request:

permissions:
  pull-requests: write
  contents: write

name: 🤞 Auto merge release

jobs:
  auto-merge:
    uses: wayofdev/gh-actions/.github/workflows/auto-merge-release.yml@master
    with:
      os: ubuntu-latest
      pull-request-number: ${{ github.event.pull_request.number }}
      actor: lotyp
      merge-method: merge
    secrets:
      # to trigger other workflows, pass PAT token instead of GITHUB_TOKEN
      token: ${{ secrets.PERSONAL_GITHUB_TOKEN }}

...
```
</details>

<br>

### → Docker Workflows

#### `build-image.yml:`

This workflow builds a docker image and pushes it to the Docker Container Registry.

Example repositories, using this workflow:

* [wayofdev/docker-node](https://github.com/wayofdev/docker-node)

**Build image with "release" tag:**

<details>
<summary><code>.github/workflows/build-release.yml</code></summary>

```yaml
---

on:  # yamllint disable-line rule:truthy
  release:
    types:
      - released

name: 🚀 Build docker images with release tag

jobs:
  prepare:
    runs-on: "ubuntu-latest"
    outputs:
      matrix: ${{ steps.matrix.outputs.matrix }}
      version: ${{ steps.version.outputs.version }}
    steps:
      - name: ⚙️ Generate matrix
        id: matrix
        run: |
          echo 'matrix={
            "os_name": ["alpine"],
            "php_version": ["8.1", "8.2"],
            "php_type": ["fpm", "cli", "supervisord"]
          }' | tr -d '\n' >> $GITHUB_OUTPUT

      - name: ⚙️ Get version for image tag
        id: version
        run: |
          version=${{ github.ref_name }}
          version=${version#v}
          echo "version=$version" >> $GITHUB_OUTPUT

  build:
    needs: prepare
    strategy:
      matrix: ${{ fromJson(needs.prepare.outputs.matrix )}}
    uses: wayofdev/gh-actions/.github/workflows/build-image.yml@master
    with:
      os: "ubuntu-latest"
      push-to-hub: true
      image-namespace: "wayofdev/php-base"
      image-template-path: "./dist/base"
      image-template: ${{ matrix.php_version }}-${{ matrix.php_type }}-${{ matrix.os_name }}
      image-version: ${{ needs.prepare.outputs.version }}
    secrets:
      docker-username: ${{ secrets.DOCKER_USERNAME }}
      docker-password: ${{ secrets.DOCKER_TOKEN }}

...
```
</details>

<br>

### → Code Architecture

#### `create-arch-diagram.yml:`

This workflow leverages the [codesee-io/codesee-action](https://github.com/Codesee-io/codesee-action) action to automatically generate architecture diagrams for your codebase whenever a pull request is made.

CodeSee is an open-source tool that helps visualize your codebase and its dependencies, making it easier for new contributors to understand the project or for maintaining a clear view of your project's architecture over time.

Here is an example of how to use this workflow:

<details>
<summary><code>.github/workflows/create-arch-diagram.yml</code></summary>

```yaml
---

on:  # yamllint disable-line rule:truthy
  push:
    branches:
      - develop
  pull_request_target:
    types:
      - opened
      - synchronize
      - reopened

name: 🤖 CodeSee

permissions: read-all

jobs:
  codesee:
    uses: wayofdev/gh-actions/.github/workflows/create-arch-diagram.yml@master
    with:
      os: ubuntu-latest
      continue-on-error: true
    secrets:
      codesee-token: ${{ secrets.CODESEE_ARCH_DIAG_API_TOKEN }}

...
```
</details>

<br>

### → Static Analysis

#### `shellcheck.yml:`

This workflow uses [redhat-plumbers-in-action/differential-shellcheck](https://github.com/redhat-plumbers-in-action/differential-shellcheck) to run shell script analysis.

Here is an example of how to use this workflow:

<details>
<summary><code>.github/workflows/shellcheck.yml</code></summary>

```yaml
---

on:  # yamllint disable-line rule:truthy
  pull_request:

name: 🐞 Differential shell-check

permissions:
  contents: read

jobs:
  shellcheck:
    uses: wayofdev/gh-actions/.github/workflows/shellcheck.yml@master
    with:
      os: ubuntu-latest
      severity: warning
    secrets:
      token: ${{ secrets.GITHUB_TOKEN }}

...
```
</details>

<br>

## 🤝 License

[![Licence](https://img.shields.io/github/license/wayofdev/gh-actions?style=for-the-badge&color=blue)](./LICENSE)

<br>

## 🔒 Security Policy

This project has a [security policy](.github/SECURITY.md).

<br>

## 🙌 Want to Contribute?

Thank you for considering contributing to the wayofdev community! We are open to all kinds of contributions. If you want to:

- 🤔 Suggest a feature
- 🐛 Report an issue
- 📖 Improve documentation
- 👨‍💻 Contribute to the code

You are more than welcome. Before contributing, kindly check our [contribution guidelines](.github/CONTRIBUTING.md).

<br>

## 🌐 Social Links

- **Twitter:** Follow our organization [@wayofdev](https://twitter.com/intent/follow?screen_name=wayofdev) and the author [@wlotyp](https://twitter.com/intent/follow?screen_name=wlotyp).
- **Discord:** Join our community on [Discord](https://discord.gg/CE3TcCC5vr).

<br>

## 👨‍💻 Author Information

Created in **2023** by [lotyp](https://github.com/wayofdev) @ [wayofdev](https://github.com/wayofdev)

<br>

## 🧱 Useful Resources

* [Composite Actions vs Reusable Workflows: what is the difference?](https://dev.to/n3wt0n/composite-actions-vs-reusable-workflows-what-is-the-difference-github-actions-11kd)

* [ergebnis/.github](https://github.com/ergebnis/.github) — Shareable actions of the [@ergebnis](https://github.com/ergebnis) organization.

* [skills/reusable-workflows](https://github.com/skills/reusable-workflows) — Reusable workflow examples

<br>
