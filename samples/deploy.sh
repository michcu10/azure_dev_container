#!/bin/bash

# Bash script to deploy the sample Bicep template
# This script demonstrates how to use the service principal authentication

set -e

# Function to display usage
usage() {
    echo "Usage: $0 -g <resource-group-name> [-l <location>] [-s <app-service-plan-sku>]"
    echo ""
    echo "Options:"
    echo "  -g    Resource group name (required)"
    echo "  -l    Location (default: eastus)"
    echo "  -s    App Service Plan SKU (default: F1)"
    echo "  -h    Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 -g my-resource-group -l westus2 -s B1"
    exit 1
}

# Parse command line arguments
while getopts "g:l:s:h" opt; do
    case $opt in
        g) RESOURCE_GROUP_NAME="$OPTARG" ;;
        l) LOCATION="$OPTARG" ;;
        s) APP_SERVICE_PLAN_SKU="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Check required parameters
if [ -z "$RESOURCE_GROUP_NAME" ]; then
    echo "❌ Error: Resource group name is required"
    usage
fi

# Set defaults
LOCATION=${LOCATION:-"eastus"}
APP_SERVICE_PLAN_SKU=${APP_SERVICE_PLAN_SKU:-"F1"}

echo "🚀 Starting deployment with the following parameters:"
echo "  Resource Group: $RESOURCE_GROUP_NAME"
echo "  Location: $LOCATION"
echo "  App Service Plan SKU: $APP_SERVICE_PLAN_SKU"
echo ""

# Check if we're logged in
echo "🔍 Checking Azure authentication..."
if ! az account show > /dev/null 2>&1; then
    echo "❌ Not logged in to Azure. Please run the login script first."
    echo "Use: ./login-with-sp.sh"
    exit 1
fi

CURRENT_ACCOUNT=$(az account show --query "user.name" -o tsv)
echo "✅ Logged in as: $CURRENT_ACCOUNT"

# Check if resource group exists, create if it doesn't
echo "📦 Checking resource group..."
if ! az group show --name "$RESOURCE_GROUP_NAME" > /dev/null 2>&1; then
    echo "Creating resource group: $RESOURCE_GROUP_NAME in $LOCATION"
    az group create --name "$RESOURCE_GROUP_NAME" --location "$LOCATION"
    echo "✅ Resource group created successfully"
else
    echo "✅ Resource group exists: $RESOURCE_GROUP_NAME"
fi

# Deploy the Bicep template
echo "🚀 Starting Bicep deployment..."
deployment_name="deployment-$(date +%Y%m%d-%H%M%S)"

az deployment group create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --template-file "main.bicep" \
    --parameters "appServicePlanSku=$APP_SERVICE_PLAN_SKU" \
    --name "$deployment_name" \
    --verbose

echo "✅ Deployment completed successfully!"
echo ""

# Get deployment outputs
echo "📋 Deployment Outputs:"
STORAGE_ACCOUNT=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$deployment_name" \
    --query "properties.outputs.storageAccountName.value" \
    --output tsv)

WEB_APP_NAME=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$deployment_name" \
    --query "properties.outputs.webAppName.value" \
    --output tsv)

WEB_APP_URL=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$deployment_name" \
    --query "properties.outputs.webAppUrl.value" \
    --output tsv)

echo "  Storage Account: $STORAGE_ACCOUNT"
echo "  Web App Name: $WEB_APP_NAME"
echo "  Web App URL: $WEB_APP_URL"
echo ""
echo "🔗 You can access your web app at: $WEB_APP_URL"
echo ""
echo "📝 To clean up resources, run:"
echo "  az group delete --name $RESOURCE_GROUP_NAME --yes --no-wait"
