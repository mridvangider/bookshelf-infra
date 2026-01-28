#!/bin/bash

ENV_FILE=env.rc

if [ ! -f "$ENV_FILE" ]
then
  echo "$ENV_FILE not found"
  exit 1
fi

if [ "$(command -v terraform >/dev/null; echo $?)" -ne 0 ]
then
  echo "terraform not available"
  exit 1
fi

ARM_SUBSCRIPTION_ID=$(az account show --query id --output tsv)
export ARM_SUBSCRIPTION_ID
terraform "$@"