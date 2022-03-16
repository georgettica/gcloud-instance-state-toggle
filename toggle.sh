#!/bin/bash

set -eEuo pipefail

REQUIRED_COMMANDS=( gcloud sudo ansible-playbook )
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
    source ./vars.env # loads the envvars
    if [[ -z "${INSTANCE_NAME}" ]] || [[ -z "${INSTANCE_ZONE}" ]]; then
	    echo "INSTANCE_NAME or INSTANCE_ZONE were not defined in ./vars.env"
	    exit 1
    fi

    local instance_status
    instance_status=$(gcp_instance_status "${INSTANCE_NAME}")
    if [[ ${instance_status} == "TERMINATED" ]]; then
        gcloud compute instances start --zone "${INSTANCE_ZONE}" "${INSTANCE_NAME}"
        sudo ./gcp-change-ip.yml -e server_name="${INSTANCE_NAME}"
    elif [[ ${instance_status} == "RUNNING" ]]; then
            gcloud compute instances stop --zone "${INSTANCE_ZONE}" "${INSTANCE_NAME}"
    fi
}

gcp_instance_status() {
    local instance_name
    instance_name="${1}"
    gcloud compute instances list --filter="${instance_name}" --format=json | jq -r '.[].status'
}

main "$@"
