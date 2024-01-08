# Custom S3 cache

This action allows caching dependencies and saving them in an AWS S3 bucket to reuse in other jobs and workflows to improve workflow execution time.


## Inputs

* `cache_action`

  Specify what to do with the cache: save to an s3 bucket or restore from the s3 bucket into `cache_path`. 

  - Type: string
  - Required
  - Possible values: save, restore

* `cache_path`

  Absolute or relative path to a folder with cache. When cache_action is **save** the path itself will not be saved, only the contents of the directory (including all subdirectories). When cache_action is **restore** all folders in `cache_path` will be created first and cache will be restored from the S3 bucket into this folder.
  
  - Type: string
  - Required
  - Default: .

* `s3_bucket_name`
  
  AWS S3 bucket name which will be used to save cache to and restore it from. 

  - Type: string
  - Required

* `cache_key`
  
  A cache key which is used only to save cache to S3 bucket
  
  - Type: string
  - Required only when `cache_action` is **save**

* `restore_keys`
  
  An ordered list of keys to use for restoring cache from the s3 bucket

  - Type: list of strings
  - Required only when `cache_action` is **restore**

  You can specify multiple keys by putting each key on its own line:
    ```yaml
    restore_keys: |-
      ${{ runner.os }}-cache-${{ hashfiles('**/.package-lock.json') }}
      ${{ runner.os }}-cache
    ```
  The first matching key will be restored. 

## Environment Variables

- `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`(Required) - credential with  access to provided AWS S3 bucket name
- `AWS_REGION`(Required) - AWS region.

## Example Cache Workflow

### Save Cache

```yaml
name: Create cache

on: push

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Create cache
      uses: wayofdev/gh-actions/actions/s3-cache@v1
      with:
        cache_action: save
        cache_path: ${GITHUB_WORKSPACE}/.cache
        s3_bucket_name: my_s3_bucket
        cache_key: ${{ runner.os }}-cache-${{ hashfiles('**/.package-lock.json') }}
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        AWS_REGION: ${{ secrets.AWS_REGION }}

```

### Restore Cache

```yaml
name: Restore cache

on: push

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Create cache
      uses: wayofdev/gh-actions/actions/s3-cache@v1
      with:
        cache_action: restore
        cache_path: ${GITHUB_WORKSPACE}/.cache
        s3_bucket_name: my_s3_bucket
        restore_keys: |
          ${{ runner.os }}-cache-${{ hashfiles('**/.package-lock.json') }}
          ${{ runner.os }}-cache
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_REGION: ${{ secrets.AWS_REGION }}
```

### Creating a Cache Key
A cache key can include any of the contexts, functions, literals, and operators supported by GitHub Actions.

For example, using the `hashFiles` function allows you to create a new cache when dependencies change. The `hashFiles` function is specific to GitHub Actions.

```yaml
    cache_key: ${{ runner.os }}-${{ hashFiles('**/lockfiles') }}
```

Additionally, you can use arbitrary command output in a cache key, such as a date or software version:

  
```yaml 
# http://man7.org/linux/man-pages/man1/date.1.html
  - name: Get Date
    id: get-date
    run: |
      echo "date=$(/bin/date -u "+%Y%m%d")" >> $GITHUB_OUTPUT
    shell: bash

  - uses: wayofdev/gh-actions/actions/s3-cache@v1
    with:
      cache_action: save
      cache_path: ${GITHUB_WORKSPACE}/.cache
      s3_bucket_name: my_s3_bucket
      cache_key: ${{ runner.os }}-${{ steps.get-date.outputs.date }}-${{ hashFiles('**/lockfiles') }}

```

See [GitHub Contexts and Expressions](https://docs.github.com/en/actions/learn-github-actions/contexts#github-context) for more cache key examples.

##  Limitations

This action has not been tested on self-hosted runners or when running inside a container.

