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

replace_dots() {
    echo "${1//./.properties.}"
}

SCRIPT_PATH=$(dirname $(realpath $0))
CHART_DIRECTORY_NAME="$1"
SCHEMA_PROPERTIES_FILE_NAME="$2"

REPOROOT=$(realpath $SCRIPT_PATH/../../)
CHART_DIRECTORY_PATH="$REPOROOT/charts/$CHART_DIRECTORY_NAME"
VALUES_SCHEMA_FILE_TEMP_PATH=$CHART_DIRECTORY_PATH/values.schema-tmp.json
VALUES_FILE_PATH=$CHART_DIRECTORY_PATH/values.yaml
VALUES_SCHEMA_FILE_PATH=$CHART_DIRECTORY_PATH/values.schema.json
SCHEMA_PROPERTY_FILE_PATH=$SCRIPT_PATH/schemaproperties/$SCHEMA_PROPERTIES_FILE_NAME

echo "Schema Property File Path: "$SCHEMA_PROPERTY_FILE_PATH
echo "Value Schema path: "$VALUES_SCHEMA_FILE_PATH
echo "Value Schema Temp Path: "$VALUES_SCHEMA_FILE_TEMP_PATH

# Check if the file exists and is readable
if [ ! -r "$SCHEMA_PROPERTY_FILE_PATH" ]; then
  echo "Error: File '$SCHEMA_PROPERTY_FILE_PATH' not found or is not readable."
  exit 1
fi

# Generating temporary schema using schema-gen utility
helm schema-gen $VALUES_FILE_PATH > $VALUES_SCHEMA_FILE_TEMP_PATH

# Read the property file line by line
PIPEDQUERY=""
while IFS= read -r line || [ -n "$line" ]; do
  if [[ "$line" =~ ^\s*# || "$line" =~ ^\s*$ ]]; then
    continue
  fi
  key=$(echo "$line" | cut -d '=' -f 1)
  value=$(echo "$line" | cut -d '=' -f 2-)
  equal=" = "
  jsonpath=$(replace_dots "$key").type
  final_key_value=$jsonpath$equal$value
  pipe=" |"
  PIPEDQUERY+=" ${final_key_value}$pipe"
done < "$SCHEMA_PROPERTY_FILE_PATH"

# Create final json schema file
JQ_QUERY=$(echo "$PIPEDQUERY" | sed 's/.\{2\}$//')
echo $JQ_QUERY
jq "$JQ_QUERY"  $VALUES_SCHEMA_FILE_TEMP_PATH > $VALUES_SCHEMA_FILE_PATH

# Removing temp json schema file
echo "Deleting values.schema-tmp.json file"
rm -rf $VALUES_SCHEMA_FILE_TEMP_PATH
echo "Done"