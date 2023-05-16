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

This repository serves as a collection of reusable GitHub Action workflows specifically designed for usage in Wayofdev projects. The workflows stored here encapsulate common and repetitive tasks, allowing them to be easily integrated into multiple projects. This not only reduces the necessity to rewrite code, but also ensures a standardized approach to common operations across all Wayofdev repositories.

## 🚀 Getting Started

To use these workflows, simply reference them from your project's workflows. Instructions for each workflow are detailed below.

Read more about [reusing workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows).

<br>

## 📑 Examples

### → `apply-labels.yml:`

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

### → `auto-merge-release.yml:`

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

### → `build-image.yml:`

This workflow builds a docker image and pushes it to the GitHub Container Registry.

Build image with "latest" tag:

```yaml
---

on: # yamllint disable-line rule:truthy
  workflow_dispatch:
  push:
    branches:
      - master
  pull_request:
    branches:
      - master

name: 🚀 Build docker images with latest tag

jobs:
  build:
    runs-on: "ubuntu-latest"
    strategy:
      fail-fast: true
      matrix:
        os_name: [ "alpine" ]
        php_version: [ "8.1", "8.2" ]
        php_type: [ "fpm", "cli", "supervisord" ]
    uses: wayofdev/gh-actions/.github/workflows/build-image.yml@master
    with:
      os: "ubuntu-latest"
      push-to-hub: ${{ github.event_name != 'pull_request' }}
      image-namespace: "wayofdev/php-base"
      image-template: ${{ matrix.php_version }}-${{ matrix.php_type }}-${{ matrix.os_name }}
      image-version: latest
    secrets:
      docker-username: ${{ secrets.DOCKER_USERNAME }}
      docker-password: ${{ secrets.DOCKER_TOKEN }}

...
```

<br>
