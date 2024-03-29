<br>

<div align="center">
<img width="456" src="https://raw.githubusercontent.com/wayofdev/gh-actions/master/assets/logo.gh-light-mode-only.png#gh-light-mode-only">
<img width="456" src="https://raw.githubusercontent.com/wayofdev/gh-actions/master/assets/logo.gh-dark-mode-only.png#gh-dark-mode-only">
</div>

<br>

<br>

<div align="center">
<a href="LICENSE.md"><img src="https://img.shields.io/github/license/wayofdev/gh-actions.svg?style=flat-square&color=blue" alt="Software License"/></a>
</div>
<br>

# Shared Github Actions

This repository is a collection of reusable GitHub Actions workflows and composite actions, specifically designed for use in Wayofdev projects. These tools encapsulate common and repetitive tasks, allowing for easy integration into multiple projects. This approach not only reduces the need to rewrite code but also ensures standardized operations across all Wayofdev repositories.

Learn more about:

- [Reusing Workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
- [Creating Composite Actions](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action)

<br>

## 📋 Table of Contents

- [Getting Started](#getting-started)
- [Workflows](#workflows)
  - [Auto Label and Release Management](#-auto-label-and-release-management)
  - [Docker](#-docker)
  - [Create Diagrams](#-create-diagrams)
  - [Static Analysis](#-static-analysis)
- [Composite Actions](#composite-actions)
  - [Dependency Management](#-dependency-management)
- [License](#license)
- [Author Information](#author-information)
- [Contributing](#want-to-contribute)

<br>

## 🚀 Getting Started

To use these workflows and actions, reference them directly from your project's workflows. Detailed instructions for each are provided below.

<br>

## ⚡️ Workflows

Read more about [reusing workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows).

### → Auto Label and Release Management

#### `apply-labels.yml:`

Automatically applies labels to pull requests based on modified paths.

This workflow triages pull requests and applies labels based on the paths that are modified in the pull request. This can help to categorize your pull requests and make it easier to identify the type of changes included.

To use this workflow, set up a `.github/labeler.yml` file with your configuration in your project. For more information on how to configure the labeler, see: https://github.com/actions/labeler/blob/master/README.md

Here is an example of how to use this workflow:

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

<br>

#### `auto-merge-release.yml:`

This workflow automatically merges releases. This workflow utilizes [peter-evans/enable-pull-request-automerge](https://github.com/peter-evans/enable-pull-request-automerge) to auto-merge releases that are created by [googleapis/release-please](https://github.com/googleapis/release-please).

Here is an example of how to use this workflow:

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

<br>

#### `create-release.yml:`

This workflow uses [google-github-actions/release-please-action](https://github.com/google-github-actions/release-please-action) to create automated releases based on [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/).

Here is an example of how to use this workflow:

```yaml
---

on:  # yamllint disable-line rule:truthy
  push:
    branches:
      - master

name: 📦 Create release

jobs:
  release:
    uses: wayofdev/gh-actions/.github/workflows/create-release.yml@master
    with:
      os: ubuntu-latest
      branch: master
      package-name: docker-php-base
    secrets:
      token: ${{ secrets.PERSONAL_GITHUB_TOKEN }}

...
```

<br>

### → Docker

#### `build-image.yml:`

This workflow builds a docker image and pushes it to the GitHub Container Registry.

Example repositories, using this workflow:

* [wayofdev/docker-php-base](https://github.com/wayofdev/docker-php-base)
* [wayofdev/docker-php-dev](https://github.com/wayofdev/docker-php-dev)
* [wayofdev/docker-node](https://github.com/wayofdev/docker-node)

**Build image with "latest" tag:**

```yaml
---

on:  # yamllint disable-line rule:truthy
  workflow_dispatch:
  pull_request:
    branches:
      - master

name: 🚀 Build docker images with latest tag

jobs:
  prepare:
    runs-on: "ubuntu-latest"
    outputs:
      matrix: ${{ steps.matrix.outputs.matrix }}
    steps:
      - name: ⚙️ Generate matrix
        id: matrix
        run: |
          echo 'matrix={
            "os_name": ["alpine"],
            "php_version": ["8.1", "8.2"],
            "php_type": ["fpm", "cli", "supervisord"]
          }' | tr -d '\n' >> $GITHUB_OUTPUT

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
      image-version: latest
    secrets:
      docker-username: ${{ secrets.DOCKER_USERNAME }}
      docker-password: ${{ secrets.DOCKER_TOKEN }}

...
```

**Build image with "release" tag:**

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

<br>

### → Create Diagrams

#### `create-arch-diagram.yml:`

This workflow leverages the [codesee-io/codesee-action](https://github.com/Codesee-io/codesee-action) action to automatically generate architecture diagrams for your codebase whenever a pull request is made.

CodeSee is an open-source tool that helps visualize your codebase and its dependencies, making it easier for new contributors to understand the project or for maintaining a clear view of your project's architecture over time.

Here is an example of how to use this workflow:

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

<br>

### → Static Analysis

#### `shellcheck.yml:`

This workflow uses [redhat-plumbers-in-action/differential-shellcheck](https://github.com/redhat-plumbers-in-action/differential-shellcheck) to run shell script analysis.

Here is an example of how to use this workflow:

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

<br>

## ⚡️ Composite Actions

Composite Actions are a powerful feature of GitHub Actions that allow you to create reusable actions using a combination of other actions, shell commands, or both. This enables you to encapsulate a sequence of steps into a single action, making your workflows more modular, easier to maintain, and reducing duplication across your projects. Composite Actions can accept inputs and use outputs, making them highly flexible and adaptable to various use cases.

### → Dependency Management

#### `composer/install:`

This action installs dependencies with Composer based on the specified dependency level (`lowest`, `locked`, `highest`). It's designed to be flexible, allowing you to specify the working directory for the Composer command.

Here is an example of how to use this action in your existing workfow:

```yaml
---

on:  # yamllint disable-line rule:truthy
  push:
    branches:
      - master
  pull_request:

name: 📥 Composer Install

jobs:
  composer-install:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os:
          - "ubuntu-latest"
        php-version:
          - "8.2"
        dependencies:
          - "locked"

    steps:
      - name: 📦 Check out the codebase
        uses: actions/checkout@v4

      - name: 📥 Install "${{ matrix.dependencies }}" dependencies
        uses: wayofdev/gh-actions/actions/composer/install@master
        with:
          dependencies: ${{ matrix.dependencies }}
          working-directory: '.'
```

<br>

#### `composer/get-cache-directory:`

This action determines the Composer cache directory and exports it as `COMPOSER_CACHE_DIR` environment variable. It allows you to specify the working directory for the Composer command to determine the cache directory.

Here is an example of how to use this action in your existing workflow:

```yaml
---

on:
  push:
    branches:
      - master
  pull_request:

name: 🗂 Get Composer Cache Directory

jobs:
  get-composer-cache-dir:
    runs-on: ubuntu-latest

    steps:
      - name: 📦 Check out the codebase
        uses: actions/checkout@v4

      - name: 🔍 Get Composer Cache Directory
        uses: wayofdev/gh-actions/actions/composer/get-cache-directory@master
        with:
          working-directory: '.'
```

<br>

#### `composer/get-root-version:`

This action determines the Composer root version based on the specified branch and exports it as `COMPOSER_ROOT_VERSION` environment variable. It's designed to be flexible, allowing you to specify both the branch and the working directory for the Composer command to determine the root version.

Here is an example of how to use this action in your existing workflow:

```yaml
---

on:
  push:
    branches:
      - master
  pull_request:

name: 🎯 Get Composer Root Version

jobs:
  get-composer-root-version:
    runs-on: ubuntu-latest

    steps:
      - name: 📦 Check out the codebase
        uses: actions/checkout@v4

      - name: 🎯 Get Composer Root Version
        uses: wayofdev/gh-actions/actions/composer/get-root-version@master
        with:
          branch: master
          working-directory: '.'
```

<br>

#### `phive/install:`

This action installs dependencies with [Phive](https://github.com/phar-io/phive), the [Phar Installer](https://phar.io), based on the specified `PHIVE_HOME` directory and a list of trusted `GPG keys`. It's designed to be flexible, allowing you to specify the `PHIVE_HOME directory` and the `GPG keys` to trust for the installation process.

Here is an example of how to use this action in your existing workflow:

```yaml
---

on:
  push:
    branches:
      - master
  pull_request:

name: 📥 Phive Install

jobs:
  phive-install:
    runs-on: ubuntu-latest

    steps:
      - name: 📦 Check out the codebase
        uses: actions/checkout@v4

      - name: 📥 Install dependencies with Phive
        uses: wayofdev/gh-actions/actions/phive/install@master
        with:
          phive-home: '.build/phive'
          trust-gpg-keys: '0x033E5F8D801A2F8D'
```

## 🤝 License

[![Licence](https://img.shields.io/github/license/wayofdev/gh-actions?style=for-the-badge&color=blue)](./LICENSE)

<br>

## 🙆🏼‍♂️ Author Information

This repository was created in **2023** by [lotyp / wayofdev](https://github.com/wayofdev).

<br>

## 🙌 Want to Contribute?

Thank you for considering contributing to the wayofdev community!
We are open to all kinds of contributions. If you want to:

- 🤔 Suggest a feature
- 🐛 Report an issue
- 📖 Improve documentation
- 👨‍💻 Contribute to the code

<br>
