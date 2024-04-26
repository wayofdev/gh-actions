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

# S3 / Cache

This GitHub Action allows you to save and restore cache artifacts from an S3 bucket. It provides a convenient way to cache dependencies, build artifacts, or any other files that can be reused across multiple workflow runs, helping to speed up your CI/CD pipeline.

<br>

## 📋 Features

- Save cache to an S3 bucket
- Restore cache from an S3 bucket
- Specify custom cache keys and restore keys
- Compress cache files using tar and gzip for efficient storage and transfer

<br>

## 📥 Inputs

- `cache-action`

  Specify what to do with the cache: save to a s3 bucket or restore from the s3 bucket into `cache_path`.

  - Type: string
  - Required
  - Possible values: save, restore

- `cache-path`

  Absolute or relative path to a folder with cache. When `cache-action` is `save` the path itself will not be saved, only the contents of the directory (including all subdirectories). When `cache-action` is `restore` all folders in `cache_path` will be created first and cache will be restored from the S3 bucket into this folder.

  - Type: string
  - Required
  - Default: .

- `s3-bucket-name`

  AWS S3 bucket name which will be used to save cache to and restore it from.

  - Type: string
  - Required

- `cache-key`

  A cache key which is used only to save cache to S3 bucket

  - Type: string
  - Required only when `cache-action` is `save`

- `restore-keys`

  An ordered list of keys to use for restoring cache from the s3 bucket

  - Type: list of strings
  - Required only when `cache-action` is `restore`

  You can specify multiple keys by putting each key on its own line:

    ```yaml
    restore-keys: |-
      ${{ runner.os }}-cache-${{ hashfiles('**/.package-lock.json') }}
      ${{ runner.os }}-cache
    ```

  The first matching key will be restored.

<br>

## 🌎 Environment Variables

The action requires the following environment variables to be set:

- `AWS_ACCESS_KEY_ID`: The AWS access key ID with permissions to access the S3 bucket.
- `AWS_SECRET_ACCESS_KEY`: The AWS secret access key associated with the access key ID.
- `AWS_REGION`: The AWS region where the S3 bucket is located.

<br>

## ⚙️ Usage Examples

### → Saving Cache

```yaml
---

name: 🔍 Continuous integration

on:  # yamllint disable-line rule:truthy
  push:

jobs:
  build:
    runs-on: ubuntu-latest
  steps:
    - name: 📦 Check out the codebase
      uses: actions/checkout@v4

    - name: 📤 Save cache
      uses: wayofdev/gh-actions/actions/s3/cache@v3.0.0
      with:
          cache-action: save
          cache-path: ./node_modules
          s3-bucket-name: my-cache-bucket
          cache-key: ${{ runner.os }}-node-modules-${{ hashFiles('**/package-lock.json') }}
      env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_REGION: ${{ secrets.AWS_REGION }}

...
```

### → Restoring Cache

```yaml
---

name: 🔍 Continuous integration

on:  # yamllint disable-line rule:truthy
  push:

jobs:
  build:
    runs-on: ubuntu-latest
  steps:
    - name: 📦 Check out the codebase
      uses: actions/checkout@v4

    - name: ♻️ Restore cache
      uses: wayofdev/gh-actions/actions/s3/cache@v3.0.0
      with:
        cache-action: restore
        cache-path: ${GITHUB_WORKSPACE}/.cache
        s3-bucket-name: my_s3_bucket
        restore-keys: |
          ${{ runner.os }}-cache-${{ hashfiles('**/.package-lock.json') }}
          ${{ runner.os }}-cache
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_REGION: ${{ secrets.AWS_REGION }}

...
```

In the restore example, the action will attempt to restore the cache using the provided `restore-keys` in the specified order. If a cache hit occurs for a key, the restoration process will stop, and the cached files will be extracted to the `cache-path`.

### → Error Handling

The action will fail if any of the required inputs or environment variables are missing or if an invalid `cache-action` is provided. Appropriate error messages will be logged to help troubleshoot the issue.

### → Creating a Cache Key

A cache key can include any of the contexts, functions, literals, and operators supported by GitHub Actions.

For example, using the `hashFiles` function allows you to create a new cache when dependencies change. The `hashFiles` function is specific to GitHub Actions.

```yaml
cache-key: ${{ runner.os }}-${{ hashFiles('**/lockfiles') }}
```

Additionally, you can use arbitrary command output in a cache key, such as a date or software version:

```yaml
---

name: 🔍 Continuous integration

on:  # yamllint disable-line rule:truthy
  push:

jobs:
  build:
    runs-on: ubuntu-latest
  steps:
    - name: Get current timestamp
      id: get-date
      run: |
        echo "date=$(/bin/date -u "+%Y%m%d")" >> $GITHUB_OUTPUT
      shell: bash

    - name: 📤 Save cache
      uses: wayofdev/gh-actions/actions/s3-cache@v1
      with:
        cache-action: save
        cache-path: ${GITHUB_WORKSPACE}/.cache
        s3-bucket-name: my_s3_bucket
        cache-key: ${{ runner.os }}-${{ steps.get-date.outputs.date }}-${{ hashFiles('**/lockfiles') }}

...
```

See [GitHub Contexts and Expressions](https://docs.github.com/en/actions/learn-github-actions/contexts#github-context) for more cache key examples.

<br>

## ☝️ Limitations

This action has not been tested on self-hosted runners or when running inside a container, or other S3 buckets, other than AWS.

<br>
