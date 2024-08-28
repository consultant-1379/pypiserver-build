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
REPOSITRY_HOSTNAME=$1
LOGIN_USERNAME=$2
PASSWORD=$3

#Creating netrc file with repository hostname and credentails for pip to access pypi repository

cat > ~/.netrc <<EOL
machine ${REPOSITRY_HOSTNAME}
	login ${LOGIN_USERNAME}
    password ${PASSWORD}
EOL
cat ~/.netrc

#Creating pypirc file with repository url and credentails for twine to access pypi repository


cat > ~/.pypirc <<EOL
[distutils]
index-servers =
    pypi

[pypi]
repository: https://${REPOSITRY_HOSTNAME}/pypi
username: ${LOGIN_USERNAME}
password: ${PASSWORD}
EOL
cat ~/.pypirc