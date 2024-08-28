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

ROBOT_TEST_SUITE_REPORT_DIR=$1
ROBOT_TEST_SUITE_TO_RUN=$2
INCLUDE_TAG="${3}"
EXCLUDE_TAG="${4}"
ROBOT_EXECUTABLE="${5:-pabot}"

NO_OF_AVAILABLE_CPUS=$(getconf _NPROCESSORS_ONLN)

PARALLEL_PROCESSES=$(($NO_OF_AVAILABLE_CPUS))

echo "Attempting to run ${PARALLEL_PROCESSES} processes in parallel"

if [[ "$INCLUDE_TAG" != "none" ]]; then
    include_tag_arr=(${INCLUDE_TAG})
    for itag in "${include_tag_arr[@]}"; do
        include_tag="${include_tag} --include ${itag}"
    done
fi

if [[ "$EXCLUDE_TAG" != "none" ]]; then
    exclude_tag_arr=(${EXCLUDE_TAG})
    for etag in "${exclude_tag_arr[@]}"; do
        exclude_tag="${exclude_tag} --exclude ${etag}"
    done
fi

export PATH=$PWD:$PATH

mkdir -p "${ROBOT_REPORTS_DIR}/${ROBOT_TEST_SUITE_REPORT_DIR}"

env
## Note: ROBOT_TESTS_DIR, ROBOT_REPORTS_DIR are env variables
if [[ "${ROBOT_EXECUTABLE}" = "robot" ]]; then
    robot --loglevel DEBUG:INFO \
        --outputdir "${ROBOT_REPORTS_DIR}/${ROBOT_TEST_SUITE_REPORT_DIR}" \
        $([ -n "${include_tag}" ] && echo "${include_tag}") \
        $([ -n "${exclude_tag}" ] && echo "${exclude_tag}") \
        "${ROBOT_TESTS_DIR}/${ROBOT_TEST_SUITE_TO_RUN}"
else
    pabot --pabotlib --testlevelsplit --processes ${PARALLEL_PROCESSES} \
        --verbose --loglevel DEBUG:INFO \
        --outputdir "${ROBOT_REPORTS_DIR}/${ROBOT_TEST_SUITE_REPORT_DIR}" \
        $([ -n "${include_tag}" ] && echo "${include_tag}") \
        $([ -n "${exclude_tag}" ] && echo "${exclude_tag}") \
        "${ROBOT_TESTS_DIR}/${ROBOT_TEST_SUITE_TO_RUN}"
fi

testExitCode=$?

if [[ -n "${testExitCode}" && ${testExitCode} -ne 0 ]]; then
    echo -e "Robot command failed with exit code ${testExitCode}"
else
    echo "Robot command executed successfully"
fi

exit ${testExitCode}
