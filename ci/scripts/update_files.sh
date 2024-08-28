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

set -ux -o pipefail;

ML_PIPELINE_PATH="$1"
PYPISERVER_IMAGE_FULL_NAME_PREFIX="$2"
CHANGED_FILES_BOBVAR_FILE="$3"

# Absolute filepath to this script
case "$(uname -s)" in
Darwin*) SCRIPT=$(greadlink -f $0) ;;
*) SCRIPT=$(readlink -f $0) ;;
esac

# Location of parent dir
BASE_DIR=$(dirname $SCRIPT)
REPOROOT=$(dirname $(dirname $BASE_DIR))
PRODUCT_INFO_FILE="charts/eric-lcm-package-repository-py/eric-product-info.yaml"
FOSSA_CONFIG_DIR="$REPOROOT/config/fossa"
ML_PIPELINE_FOSSA_CONFIG_DIR="config/fossa"

# derive 
dockerRegistry=$(echo $PYPISERVER_IMAGE_FULL_NAME_PREFIX | awk -F/ '{print $1}')  ## not used
pypiserverImageRepo=$(echo $PYPISERVER_IMAGE_FULL_NAME_PREFIX | awk -F/ '{print $2"/"$3}')
pypiserverImageNamePrefix=$(echo $PYPISERVER_IMAGE_FULL_NAME_PREFIX | awk -F/ '{print $4}' | awk -F: '{print $1}')
pypiserverImageVersion=$(echo $PYPISERVER_IMAGE_FULL_NAME_PREFIX | awk -F/ '{print $4}' | awk -F: '{print $2}')

imageIds=( "pypiserver" )

filesToSync=()

for imageId in "${imageIds[@]}"
do 
    echo "Set ${pypiserverImageNamePrefix}-${imageId} docker repo to ${pypiserverImageRepo}"
    image=$pypiserverImageNamePrefix-${imageId} repoPath=$pypiserverImageRepo yq e -i '.images[env(image)].repoPath = env(repoPath)' "${ML_PIPELINE_PATH}/$PRODUCT_INFO_FILE"
    echo "Set ${pypiserverImageNamePrefix}-${imageId} docker image version to ${pypiserverImageVersion}"
    image=$pypiserverImageNamePrefix-${imageId} tag=$pypiserverImageVersion yq e -i '.images[env(image)].tag = env(tag)' "${ML_PIPELINE_PATH}/$PRODUCT_INFO_FILE"
done 

changedFiles=($PRODUCT_INFO_FILE)

# Add new line after license header. It is lost due to yq manipulation
sed -i '/^productName:.*/i \ ' "${ML_PIPELINE_PATH}/$PRODUCT_INFO_FILE"

filesToSync=(
    "dependencies.pypiserver.yaml"
    "foss.usage.pypiserver.yaml"
    "license-agreement-pypiserver.json"
)

if [ ! -d "$ML_PIPELINE_PATH/${ML_PIPELINE_FOSSA_CONFIG_DIR}" ]; then
    mkdir -p "$ML_PIPELINE_PATH/${ML_PIPELINE_FOSSA_CONFIG_DIR}"
fi

for file in "${filesToSync[@]}"; do
    echo "Syncing ${file} from ${FOSSA_CONFIG_DIR} to ${ML_PIPELINE_FOSSA_CONFIG_DIR}}"
    echo "Check if there are changes in $file"
    if [ -f $ML_PIPELINE_PATH/${ML_PIPELINE_FOSSA_CONFIG_DIR}/$file ]
    then
        diff $FOSSA_CONFIG_DIR/$file $ML_PIPELINE_PATH/${ML_PIPELINE_FOSSA_CONFIG_DIR}/$file
        diffStatus=$?
    else 
        diffStatus=1
    fi
    if [ $diffStatus -eq 0 ]; then
        echo "No changes in $file"
    else
        echo "Detected changes in $file"
        changedFiles+=("${ML_PIPELINE_FOSSA_CONFIG_DIR}/$file")
        echo "Copy $file to $ML_PIPELINE_PATH/${ML_PIPELINE_FOSSA_CONFIG_DIR}/$file"
        cp $FOSSA_CONFIG_DIR/$file $ML_PIPELINE_PATH/${ML_PIPELINE_FOSSA_CONFIG_DIR}/$file
    fi
done

printf '%s\n' "${changedFiles[@]}" > $CHANGED_FILES_BOBVAR_FILE

