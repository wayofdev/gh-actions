<br>
<div align="center">
<img width="456" src="https://raw.githubusercontent.com/wayofdev/gh-actions/master/assets/logo.gh-light-mode-only.png#gh-light-mode-only" alt="WayOfDev Logo for light theme">
<img width="456" src="https://raw.githubusercontent.com/wayofdev/gh-actions/master/assets/logo.gh-dark-mode-only.png#gh-dark-mode-only" alt="WayOfDev Logo for dark theme">
</div>
<br>
<br>

<div align="center">
<a href="https://github.com/wayofdev/gh-actions/actions" target="_blank"><img alt="Build Status" src="https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fwayofdev%2Fgh-actions%2Fbadge&style=flat-square"/></a>
<a href="../../../LICENSE.md"><img src="https://img.shields.io/github/license/wayofdev/gh-actions.svg?style=flat-square&color=blue" alt="Software License"/></a>
<a href="" target="_blank"><img alt="Commits since latest release" src="https://img.shields.io/github/commits-since/wayofdev/gh-actions/latest?style=flat-square"></a>
<a href="https://discord.gg/CE3TcCC5vr" target="_blank"><img alt="Codecov" src="https://img.shields.io/discord/1228506758562058391?style=flat-square&logo=discord&labelColor=7289d9&logoColor=white&color=39456d"></a>
<a href="https://twitter.com/intent/follow?screen_name=wayofdev" target="_blank"><img src="https://img.shields.io/twitter/follow/wayofdev.svg?style=flat-square&logo=x&color=6e7781"></a>
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

name: 🎯 Get Composer Root Version

jobs:
  integrate:
    runs-on: ubuntu-latest

    steps:
      - name: 📦 Check out the codebase
        uses: actions/checkout@v4

      - name: 🎯 Get Composer Root Version
        uses: wayofdev/gh-actions/actions/composer/get-root-version@master
        with:
          branch: master
          working-directory: '.'

...
```

For details, see [`actions/composer/get-root-version/action.yml`](./action.yml).

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
