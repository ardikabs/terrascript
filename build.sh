#!/bin/bash
set -ueo pipefail

case $(uname -s) in
  Linux)
    SED="sed --in-place='.1'"
    ;;
  Darwin)
    SED="sed -i '.1'"
    ;;
esac

SED_ARGS="-e \"s/^TERRASCRIPT_VERSION=.*/TERRASCRIPT_VERSION=${VERSION}/g\" $(git rev-parse --show-toplevel)/terrascript"

eval "$SED $SED_ARGS"

docker build \
  -t ardikabs/terrascript:latest \
  -t ardikabs/terrascript:"${VERSION}" \
  --build-arg TERRAFORM_VERSION="${TERRAFORM_VERSION}" \
  --build-arg GIT_COMMIT="${GIT_COMMIT}" \
  -f build/Dockerfile .

mv "$(git rev-parse --show-toplevel)/terrascript.1" "$(git rev-parse --show-toplevel)/terrascript"