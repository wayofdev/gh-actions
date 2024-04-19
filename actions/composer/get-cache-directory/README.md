<br>
<div align="center">
<img width="456" src="https://raw.githubusercontent.com/cycle/gh-actions/master/assets/logo.gh-light-mode-only.png#gh-light-mode-only" alt="WayOfDev Logo for light theme">
<img width="456" src="https://raw.githubusercontent.com/cycle/gh-actions/master/assets/logo.gh-dark-mode-only.png#gh-dark-mode-only" alt="WayOfDev Logo for dark theme">
</div>
<br>
<br>

<div align="center">
<a href="https://github.com/cycle/gh-actions/actions" target="_blank"><img alt="Build Status" src="https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fwayofdev%2Fgh-actions%2Fbadge&style=flat-square"/></a>
<a href="../../../LICENSE.md"><img src="https://img.shields.io/github/license/cycle/gh-actions.svg?style=flat-square&color=blue" alt="Software License"/></a>
<a href="https://github.com/cycle/gh-actions" target="_blank"><img alt="Commits since latest release" src="https://img.shields.io/github/commits-since/cycle/gh-actions/latest?style=flat-square"></a>
<a href="https://conventionalcommits.org" target="_blank"><img alt="Conventional Commits" src="https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg?style=flat-square&label=conventional%20commits"></a>
<a href="https://discord.gg/CE3TcCC5vr" target="_blank"><img alt="Codecov" src="https://img.shields.io/discord/1228506758562058391?style=flat-square&logo=discord&labelColor=7289d9&logoColor=white&color=39456d"></a>
<a href="https://twitter.com/intent/follow?screen_name=wayofdev" target="_blank"><img src="https://img.shields.io/twitter/follow/wayofdev.svg?style=flat-square&logo=x&color=6e7781"></a>
</div>

<br>

# Composer / Get Cache Directory Action

This action determines the Composer cache directory and exports it as `COMPOSER_CACHE_DIR` environment variable. It allows you to specify the working directory for the Composer command to determine the cache directory.

<br>

## Example Usage

Create a new workflow file, for example, `.github/workflows/integrate.yml`, and add the following code to it.

```yaml
---

on:
  push:
    branches:
      - master
  pull_request:

name: 🔍 Continuous integration

jobs:
  integrate:
    runs-on: ubuntu-latest
    steps:
      - name: 📦 Check out the codebase
        uses: actions/checkout@v4

      # ...

      - name: 🎯 Get Composer Cache Directory
        uses: cycle/gh-actions/actions/composer/get-cache-directory@master
        with:
          working-directory: '.'

      # ...

...
```

For details, see [`actions/composer/get-cache-directory/action.yml`](./action.yml) file.

Real-world examples can be found in the [`wayofdev/laravel-package-tpl`](https://github.com/wayofdev/laravel-package-tpl/blob/master/.github/workflows/integrate.yml) repository.

<br>

## Structure

### Inputs

- `working-directory`, optional: The working directory to use. Defaults to `"."`.

### Outputs

none

### Side Effects

- The `COMPOSER_CACHE_DIR` environment variable contains the path to the composer cache directory.

<br>
