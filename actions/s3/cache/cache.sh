#!/usr/bin/env bash

set -euo pipefail

function save_cache() {

    if [[ $(aws s3 ls s3://"${S3_BUCKET}"/"${CACHE_KEY}"/ --region "$AWS_REGION" | head) ]]; then
        echo "Cache is already existed for key: ${CACHE_KEY}"
    else
        echo "Saving cache for key ${CACHE_KEY}"

        tmp_dir="$(mktemp -d)"
        (cd "$CACHE_PATH" && tar czf "${tmp_dir}/archive.tgz" ./*)
        local size="$(ls -lh "${tmp_dir}/archive.tgz" | cut -d ' ' -f 5 )"

        aws s3 cp "${tmp_dir}/archive.tgz" "s3://${S3_BUCKET}/${CACHE_KEY}/archive.tgz" --region "$AWS_REGION" > /dev/null
        local copy_exit_code=$?
        rm -rf "${tmp_dir}"
        echo "Cache size: ${size}"

        if [[ "${copy_exit_code}" == 0 ]]; then
            echo "Cache saved successfully for key: ${CACHE_KEY}"
        fi
    fi
}

function restore_cache() {

    for key in ${RESTORE_KEYS}; do
        if [[ $(aws s3 ls s3://"${S3_BUCKET}"/ --region "$AWS_REGION" | grep "$key" | head) ]]; then
            local k=$(aws s3 ls s3://"${S3_BUCKET}"/ --region "$AWS_REGION" | grep "$key" | head -n 1 | awk '{print $2}')
            tmp_dir="$(mktemp -d)"
            mkdir -p "$CACHE_PATH"

            aws s3 cp s3://"${S3_BUCKET}"/"${k//\//}"/archive.tgz "$tmp_dir"/archive.tgz --region "$AWS_REGION" > /dev/null
            tar xzf "${tmp_dir}/archive.tgz" -C "$CACHE_PATH"

            echo "Restoring cache for key ${key}"
            du -sm "${CACHE_PATH}"/*
            exit 0
        else
            echo "Cache with key $key not found."
        fi
    done
}

# Check if all necessary variables are set

if [[ -z "$INPUT_CACHE_ACTION" && -z "$INPUT_S3_BUCKET_NAME" ]]; then
    echo "::error::Required inputs are missing: cache_action, s3_bucket_name and either cache_key (if cache_action is save) or restore_keys (if cache_action is restore) must be set."
    exit 1

fi

if [[ "$INPUT_CACHE_ACTION" != 'save' ]] && [[ "$INPUT_CACHE_ACTION" != 'restore' ]]; then
    echo "::error::Incorrect cache_action. Must be 'save' or 'restore'."
    exit 1
fi

if [[ "$INPUT_CACHE_ACTION" == "save" && -z "$INPUT_CACHE_KEY" ]]; then
    echo "::error::Required inputs are missing: cache_action, s3_bucket_name and either cache_key (if cache_action is save) or restore_keys (if cache_action is restore) must be set."
    exit 1
fi

if [[ "$INPUT_CACHE_ACTION" == "restore" && -z "$INPUT_RESTORE_KEYS" ]]; then
    echo "::error::Required inputs are missing: cache_action, s3_bucket_name and either cache_key (if cache_action is save) or restore_keys (if cache_action is restore) must be set."
    exit 1
fi

if [[ ! -v AWS_ACCESS_KEY_ID || ! -v AWS_SECRET_ACCESS_KEY || ! -v AWS_REGION ]]; then
    echo "::error::AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_REGION must be set"
    exit 1
fi

# Main logic

if [[ -v INPUT_CACHE_PATH ]]; then
    CACHE_PATH=$INPUT_CACHE_PATH
fi
S3_BUCKET=$INPUT_S3_BUCKET_NAME

if [[ "$INPUT_CACHE_ACTION" == "save" ]]; then
    CACHE_KEY=$INPUT_CACHE_KEY
    save_cache
else
    RESTORE_KEYS=$INPUT_RESTORE_KEYS
    restore_cache
fi
