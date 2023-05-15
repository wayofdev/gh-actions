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

Shared github action workflows for usage in Wayofdev projects.

<br>

## 📑 Examples

### → `apply-labels.yml:`

This workflow will triage pull requests and apply a label based on the paths that are modified in the pull request.

To use this workflow, you will need to set up a `.github/labeler.yml` file with configuration. For more information, see: https://github.com/actions/labeler/blob/master/README.md

```yaml
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
