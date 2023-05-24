#!/bin/bash
set -eo pipefail

# This will load the script from this repository. Make sure to point to a specific commit so the build continues to work
# event if breaking changes are introduced in this repository
source /dev/stdin <<< "$(curl -s https://raw.githubusercontent.com/manastech/ci-docker-builder/055890240f6cfd633839bb32f8d4deef83214aed/build.sh)"

# Prepare the build
dockerSetup

# Write a VERSION file for the footer
echo $VERSION > VERSION

# Build and push the Docker image
dockerBuildAndPush
