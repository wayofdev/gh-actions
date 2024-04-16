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

# Playwright / Install

This GitHub Action installs [Playwright](https://playwright.dev/) along with its dependencies. Playwright is a framework for browser-based automation and testing across multiple browsers. This action supports custom configurations for cache directories and the installation of specific browsers, tailored for efficient testing environments in CI workflows.

<br>

## Example Usage

Create a new workflow file, for example, `.github/workflows/test.yml`, and add the following code to it.

```yaml
---

on:
  push:
    branches:
      - master
  pull_request:

name: 🎭 Playwright Setup

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - name: 📦 Check out the codebase
        uses: actions/checkout@v4

      - name: 🎭 Setup Playwright
        uses: wayofdev/gh-actions/actions/playwright/install@master
        with:
          playwright-cache-folder: '~/.cache/ms-playwright'
          cache-prefix: 'ci-tests'
          browsers: 'chromium webkit'

...
```

For details, see [`actions/playwright/install/action.yml`](https://chat.openai.com/c/action.yml).

<br>

## Structure

### Inputs

- `playwright-cache-folder`, optional: Specifies the directory for caching Playwright installations. Defaults to `~/.cache/ms-playwright`.
- `cache-prefix`, optional: A prefix used to invalidate the cache in case of issues. Defaults to `default`.
- `browsers`, optional: Specifies which browsers to install. Defaults to `"chromium webkit"`.

### Outputs

none

### Side Effects

- Custom configurations are used to set up the Playwright environment, specifically targeting cache management and browser installation.
- The caching mechanism is optimized with a dynamically generated cache key that considers the OS, Playwright version, browser selection, and any specified cache prefix.
- If the cache does not match the current requirements (e.g., due to a version update or change in selected browsers), Playwright will reinstall the necessary components.

<br>
