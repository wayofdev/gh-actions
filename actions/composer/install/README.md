<div align="center">
    <br>
    <a href="https://wayof.dev" target="_blank">
        <picture>
            <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/wayofdev/.github/master/assets/logo.gh-dark-mode-only.png">
            <img width="400" src="https://raw.githubusercontent.com/wayofdev/.github/master/assets/logo.gh-light-mode-only.png" alt="WayOfDev Logo">
        </picture>
    </a>
    <br>
    <br>
</div>

<div align="center">
<a href="https://github.com/wayofdev/gh-actions/actions" target="_blank"><img alt="Build Status" src="https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fwayofdev%2Fgh-actions%2Fbadge&style=flat-square&label=github%20actions"/></a>
<a href="https://github.com/wayofdev/gh-actions" target="_blank"><img alt="Commits since latest release" src="https://img.shields.io/github/commits-since/wayofdev/gh-actions/latest?style=flat-square"></a>
<a href="https://discord.gg/CE3TcCC5vr" target="_blank"><img alt="Codecov" src="https://img.shields.io/discord/1228506758562058391?style=flat-square&logo=discord&labelColor=7289d9&logoColor=white&color=39456d"></a>
<a href="https://x.com/intent/follow?screen_name=wayofdev" target="_blank"><img alt="Follow on Twitter (X)" src="https://img.shields.io/badge/-Follow-black?style=flat-square&logo=X"></a>
</div>

<br>

# Composer / Install

This action installs dependencies with Composer based on the specified dependency level (`lowest`, `locked`, `highest`). It's designed to be flexible, allowing you to specify the working directory for the Composer command.

<br>

## Example Usage

Create a new workflow file, for example, `.github/workflows/integrate.yml`, and add the following code to it.

```yaml
---

on:  # yamllint disable-line rule:truthy
  push:
    branches:
      - master
  pull_request:

name: 🔍 Continuous integration

jobs:
  integrate:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os:
          - ubuntu-latest
        php-version:
          - '8.1'
          - '8.2'
          - '8.3'
        dependencies:
          - lowest
          - locked
          - highest

    steps:
      - name: 📦 Check out the codebase
        uses: actions/checkout@v4

      # ...

      - name: 📥 Install "${{ matrix.dependencies }}" dependencies
        uses: wayofdev/gh-actions/actions/composer/install@master
        with:
          dependencies: ${{ matrix.dependencies }}
          working-directory: '.'

      # ...

...
```

For details, see [`actions/composer/install/action.yaml`](actions/composer/install/action.yaml).

Real-world examples can be found in the [`wayofdev/laravel-package-tpl`](https://github.com/wayofdev/laravel-package-tpl/blob/master/.github/workflows/integrate.yml) repository.

<br>

## Structure

### Inputs

- `dependencies`, optional: Which dependencies to install, one of `"lowest"`, `"locked"`, `"highest"`
- `working-directory`, optional: The working directory to use, defaults to `"."`.

### Outputs

none

### Side Effects

- When `dependencies` is set to `"lowest"`, dependencies are installed in the directory specified by `working-directory` with

  ```bash
  composer update --ansi --no-interaction --no-progress --prefer-lowest
  ````

- When `dependencies` is set to `"locked"`, dependencies are installed in the directory specified by `working-directory` with

  ```bash
  composer install --ansi --no-interaction --no-progress
  ```

- When `dependencies` is set to `"highest"`, dependencies are installed in the directory specified by `working-directory` with

  ```bash
  composer update --ansi --no-interaction --no-progress
  ````

<br>
