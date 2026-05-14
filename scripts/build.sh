#!/bin/bash

set -e

pushd "$(dirname "$0")/.."

docker \
    buildx \
        build \
            --platform linux/amd64,linux/arm64 \
            . \
            --tag ghcr.io/gitgc/home-proxy-webserver:main
popd
