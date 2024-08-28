#! /usr/bin/env bash
#
# COPYRIGHT Ericsson 2023
#
#
#
# The copyright to the computer program(s) herein is the property of
#
# Ericsson Inc. The programs may be used and/or copied only with written
#
# permission from Ericsson Inc. or in accordance with the terms and
#
# conditions stipulated in the agreement/contract under which the
#
# program(s) have been supplied.
#

set -x
set -e

CWD=$(pwd)

case "$(uname -s)" in
Darwin*) SCRIPT=$(greadlink -f $0) ;;
*) SCRIPT=$(readlink -f $0) ;;
esac

# Absolute path this script is in. /home/user/bin
BASEDIR=$(dirname $SCRIPT)
MODULEROOT=$(dirname $BASEDIR)

cleanup() {
if [[ -d "${BASEDIR}/pypiserver" ]]; then
    rm -rf "${BASEDIR}/pypiserver"
fi
}

COMMON_BASE_OS_VERSION=6.0.0-18
VERSION=0.3
BUILD_NO=01
IMAGE="armdocker.rnd.ericsson.se/proj-mxe-ci-internal/python-packages-loader:${VERSION}-${COMMON_BASE_OS_VERSION}"
if [[ -n "${BUILD_NO}" ]]; then
    IMAGE="${IMAGE}-${BUILD_NO}"
fi

DOCKER_BUILDKIT=1 docker build --build-arg COMMON_BASE_OS_VERSION=${COMMON_BASE_OS_VERSION} \
    --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
    -t ${IMAGE} "${BASEDIR}"
buildStatus=$?

if [[ $buildStatus == 0 ]]; then
    docker push ${IMAGE}
    pushed=$?
    if [[ $pushed == 0 ]]; then
        cleanup
    fi
else
    echo "Docker build failed"
fi
