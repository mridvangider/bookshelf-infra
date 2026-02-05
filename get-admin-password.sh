#!/bin/sh
# shellcheck disable=SC1090

output_file=$1
key_vault_env_file=$2

if [ ! -f "$key_vault_env_file" ]
then
  echo "key_vault_env_file could not be found"
  exit 1
fi

set -a
. "$key_vault_env_file"
set +a

db_admin_password=$(az keyvault secret show --id "$ADMIN_PASSWORD_SECRET_ID" --query "value" --output tsv)
db_admin_password_version=$(az keyvault secret show --id "$ADMIN_PASSWORD_VERSIN_SECRET_ID" --query "value" --output tsv)


cat >"$output_file" <<EOF
db_admin_password = "$db_admin_password"
db_admin_password_version = $db_admin_password_version
EOF