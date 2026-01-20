#!/bin/sh

if [ $(command -v az >/dev/null; echo $?) -ne 0 ]; then
    echo "Azure CLI is not installed."
    exit 1
fi

if [ ! az account show >/dev/null 2>&1 ]; then
    echo "You are not logged in to Azure CLI."
    exit 1
fi

ARM_SUBSCRIPTION_ID=$(az account show --query id --output tsv)
ARM_TENANT_ID=$(az account show --query tenantId --output tsv)
ARM_CLIENT_ID=$(az ad sp show --id $(az account show --query user.name --output tsv) --query appId --output tsv)
ARM_USE_OIDC=true
ARM_OIDC_AZURE_SERVICE_CONNECTION_ID=tf-sp-on-ado

test -f build.env && rm build.env

cat > build.env <<EOF
export ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID
export ARM_TENANT_ID=$ARM_TENANT_ID
export ARM_CLIENT_ID=$ARM_CLIENT_ID
export ARM_USE_OIDC=$ARM_USE_OIDC
export ARM_OIDC_AZURE_SERVICE_CONNECTION_ID=$ARM_OIDC_AZURE_SERVICE_CONNECTION_ID
EOF