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


set -eux -o pipefail

SCRIPT_PATH=$(dirname $(realpath $0))
REPOROOT=$(realpath $SCRIPT_PATH/../../)

VALUES_FILE="$1"

echo "Environment variables"
printenv


echo "Adding helm repos"
helm repo add mlops $PYTHON_PKG_REPO_CHART_REPO --username $SELI_ARTIFACTORY_REPO_USER --password $SELI_ARTIFACTORY_REPO_PASS --force-update
helm repo add adp https://arm.rnd.ki.sw.ericsson.se/artifactory/proj-adp-gs-released-helm/ --username $SELI_ARTIFACTORY_REPO_USER --password $SELI_ARTIFACTORY_REPO_PASS --force-update


if [ "notset" = "${LOGSHIPPER_CHART_VERSION}" ];
then
  LOGSHIPPER_CHART_VERSION=`helm search repo adp/eric-log-shipper -o json | jq '.[0].version'`
  echo "Logshipper version set to ${LOGSHIPPER_CHART_VERSION}"
fi

echo "Preparing logshipper integration chart for local installation"
echo "Replacing dynamic props in $REPOROOT/ci/logshipper-integration/python-package-repo-integ/Chart.yaml"


echo "LOGSHIPPER_CHART_VERSION=$LOGSHIPPER_CHART_VERSION"
echo "PYTHON_PKG_REPO_CHART_VERSION=$PYTHON_PKG_REPO_CHART_VERSION"
echo "PYTHON_PKG_REPO_CHART_REPO=$PYTHON_PKG_REPO_CHART_REPO"
echo "K8S_NAMESPACE=$K8S_NAMESPACE"

sed "s#LOGSHIPPER_CHART_VERSION#$LOGSHIPPER_CHART_VERSION#g; 
        s#PYTHON_PKG_REPO_CHART_VERSION#$PYTHON_PKG_REPO_CHART_VERSION#g; 
        s#PYTHON_PKG_REPO_CHART_REPO#$PYTHON_PKG_REPO_CHART_REPO#g" $REPOROOT/ci/logshipper-integration/Chart.yaml.tmpl > $REPOROOT/ci/logshipper-integration/python-package-repo-integ/Chart.yaml

echo "Running helm dependency update for $REPOROOT/ci/logshipper-integration/python-package-repo-integ"
helm dependency update $REPOROOT/ci/logshipper-integration/python-package-repo-integ

echo "Prefixing eric-lcm-package-repository-py tag in ${VALUES_FILE} so that it can be used in integration chart"
yq '{"eric-lcm-package-repository-py": .}' ${VALUES_FILE} > ${VALUES_FILE}_integ

echo "Installing logshipper integration chart"
helm upgrade $HELM_RELEASE $REPOROOT/ci/logshipper-integration/python-package-repo-integ \
        --install --debug --namespace ${K8S_NAMESPACE} \
        --values  ${VALUES_FILE}_integ --wait --timeout 15m0s
