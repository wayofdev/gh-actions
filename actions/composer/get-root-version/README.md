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

# Composer / Get Root Version

This action determines the Composer root version based on the specified branch and exports it as `COMPOSER_ROOT_VERSION` environment variable. It's designed to be flexible, allowing you to specify both the branch and the working directory for the Composer command to determine the root version.

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

      - name: 🎯 Get Composer Root Version
        uses: wayofdev/gh-actions/actions/composer/get-root-version@master
        with:
          branch: master
          working-directory: '.'

      # ...

...
```

For details, see [`actions/composer/get-root-version/action.yml`](./action.yml).

Real-world examples can be found in the [`wayofdev/laravel-package-tpl`](https://github.com/wayofdev/laravel-package-tpl/blob/master/.github/workflows/integrate.yml) repository.

<br>

## Structure

### Inputs

- `branch`, optional: The name of the branch, defaults to `"master"`.
- `working-directory`, optional: The working directory to use, defaults to `"."`.

### Outputs

none

### Side Effects

- The `COMPOSER_ROOT_VERSION` environment variable contains the root version if it has been defined as `branch-alias` in `composer.json`.

  ```json
  {
    "extra": {
      "branch-alias": {
        "dev-master": "11.0-dev"
      }
    }
  }
  ```

<br>
