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

FILE_NAME=$1
LCM_PYPISERVER_HOST=$2
LCM_PYPISERVER_USERNAME=$3
LCM_PYPISERVER_PASSWORD=$4

cat >"${FILE_NAME}" << EOF
repository_hostname = "${LCM_PYPISERVER_HOST}"
repository_url = 'https://${LCM_PYPISERVER_HOST}/pypi'
username = '${LCM_PYPISERVER_USERNAME}'
password = '${LCM_PYPISERVER_PASSWORD}'
EOF