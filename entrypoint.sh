#!/bin/bash

set -e

if [ -z ${ACCESS_TOKEN+x} ]; then
    echo "ACCESS_TOKEN is not set"
    exit 1
fi

if [ -z ${MODE+x} ]; then
    echo "MODE is not set"
    exit 1
fi

if [ -z ${SOURCE+x} ]; then
    echo "SOURCE is not set"
    exit 1
fi

if [ "${MODE}" != "org" ] && [ "${MODE}" != "repo" ]; then
    echo "MODE should be either 'org' or 'repo'"
    exit 1
fi

if [ "${MODE}" == "repo" ] && [ "${SOURCE}" == *"/"* ]; then
    echo "when MODE = 'repo', SOURCE should contains '/'"
    exit 1
fi

REG_TOKEN=$( \
    curl \
        -sX POST \
        -H "Authorization: token ${ACCESS_TOKEN}" \
        https://api.github.com/${MODE}s/${SOURCE}/actions/runners/registration-token \
    | jq .token --raw-output \
)

cd actions-runner

./config.sh --ephemeral --unattended --url https://github.com/${SOURCE} --token ${REG_TOKEN}

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
