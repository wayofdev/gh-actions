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

# PNPM / Install

This GitHub Action installs mono-repository dependencies using [PNPM](https://pnpm.io/). It's designed to efficiently handle dependencies in a mono-repository setup, enabling `corepack` support and caching node modules to speed up builds.

This action is ideal for projects that require optimal dependency management and fast execution of workflows within CI environments.

<br>

## Example Usage

Create a new workflow file, for example, `.github/workflows/build.yml`, and add the following code to it.

```yaml
---

on:
  push:
    branches:
      - master
  pull_request:

name: 🔍 Continuous integration for web app

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: 📦 Check out the codebase
        uses: actions/checkout@v4

     # ...

      - name: ⚙️ Setup PNPM mono-repository
        uses: wayofdev/gh-actions/actions/pnpm/install@master
        with:
          cwd: '.'
          enable-corepack: true
          cache-prefix: 'ci-build'
          cache-node-modules: true

    # ...

...
```

For details, see [`actions/pnpm/install/action.yml`](./action.yml).

Real-world examples can be found in the [`wayofdev/next-starter-tpl`](https://github.com/wayofdev/next-starter-tpl/blob/master/.github/workflows/ci-apps-web.yml) repository.

<br>

## Structure

### Inputs

- `cwd`, optional: Changes Node's process current working directory. Defaults to the root directory (`.`).
- `enable-corepack`, optional: Enables `corepack` to manage package installations. Defaults to `false`.
- `cache-prefix`, optional: Specifies a custom prefix for caching mechanisms. Defaults to `default`.
- `cache-node-modules`, optional: Enables caching of `node_modules` directories. Defaults to `false`.

### Outputs

none

### Side Effects

- Enabling `corepack` sets up the package manager environment using the system's [corepack](https://nodejs.org/api/corepack.html) feature.
- PNPM is installed or configured according to the presence of `corepack`.
- Caching keys are created and used for faster retrieval of the `node_modules` and pnpm store directories.
- Dependencies are installed with options such as `--no-frozen-lockfile`, `--strict-peer-dependencies`, and `--prefer-offline` to ensure consistency and reproducibility across installations.

<br>
