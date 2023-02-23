#!/bin/sh

WORKFLOW_NAME="Test Firmwares"
CONCLUSION="failure"
LIMIT=50
ARTIFACT_NAME="pytest-logs"

FAILED_WF=$(gh run list -L ${LIMIT}  --json conclusion,databaseId,createdAt,displayTitle -w "${WORKFLOW_NAME}" | jq ".[] | select(.conclusion == \"${CONCLUSION}\")" | jq -s ".")
for f in $(echo ${FAILED_WF} | jq -r '.[] | @base64'); do
    ts=$(echo ${f} | base64 --decode | jq -r '.createdAt')
    title=$(echo ${f} | base64 --decode | jq -r '.displayTitle')
    dbid=$(echo ${f} | base64 --decode | jq '.databaseId')
    title=$(echo ${title} | sed 's/ /_/g')
    echo "Processing action created at ${ts} for ${title}"
    gh run download -D actions_logs/${title}_${ts} -n "${ARTIFACT_NAME}" ${dbid}
done
