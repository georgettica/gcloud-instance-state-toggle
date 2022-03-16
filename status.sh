#!/bin/bash

set -eEuo pipefail

REQUIRED_COMMANDS=( 
	gcloud
	jq
)
# Check required commands are in $PATH
for cmd in "${REQUIRED_COMMANDS[@]}"
do
  if ! command -v "${cmd}" > /dev/null
  then
    echo -e "Command $cmd is required for this script to work.\n"
    usage
    exit 1
   fi
done


main() {
    # loads the envvars
    source ./vars.env 
    if [[ -z "${INSTANCE_NAME}" ]]; then
	    echo "INSTANCE_NAME was not defined in ./vars.env"
	    exit 1
    fi
    gcp_instance_status "${INSTANCE_NAME}"
}

gcp_instance_status() {
    local instance_name
    instance_name="${1}"
    gcloud compute instances list --filter="${instance_name}" --format=json | jq -r '.[].status'
}

main "$@"
