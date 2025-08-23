#!/bin/bash

# Script to create a service principal for Azure Dev Container

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo -e "${BLUE}Usage: $0 [OPTIONS]${NC}"
    echo ""
    echo "Options:"
    echo "  -n, --name NAME        Service principal name (default: dev-container-sp)"
    echo "  -r, --role ROLE        Azure role (default: Contributor)"
    echo "  -s, --subscription ID  Subscription ID (will prompt if not provided)"
    echo "  -g, --resource-group   Resource group name (optional, for resource group scope)"
    echo "  -o, --output FILE      Output file for credentials (default: sp-credentials.json)"
    echo "  -h, --help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -s 12345678-1234-1234-1234-123456789012"
    echo "  $0 -s 12345678-1234-1234-1234-123456789012 -g my-dev-rg"
    echo "  $0 -n my-custom-sp -r Reader -s 12345678-1234-1234-1234-123456789012"
    exit 1
}

# Parse command line arguments
SP_NAME="dev-container-sp"
ROLE="Contributor"
SUBSCRIPTION_ID=""
RESOURCE_GROUP=""
OUTPUT_FILE="sp-credentials.json"

while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--name)
            SP_NAME="$2"
            shift 2
            ;;
        -r|--role)
            ROLE="$2"
            shift 2
            ;;
        -s|--subscription)
            SUBSCRIPTION_ID="$2"
            shift 2
            ;;
        -g|--resource-group)
            RESOURCE_GROUP="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            ;;
    esac
done

echo -e "${GREEN}🔐 Azure Service Principal Creation Tool${NC}"
echo ""

# Check if Azure CLI is installed and user is logged in
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if user is logged in
if ! az account show &> /dev/null; then
    echo -e "${RED}❌ Not logged in to Azure. Please run 'az login' first.${NC}"
    exit 1
fi

# Get subscription ID if not provided
if [ -z "$SUBSCRIPTION_ID" ]; then
    echo -e "${YELLOW}📋 Getting available subscriptions...${NC}"
    az account list --query "[].{name:name, id:id}" -o table

    echo ""
    echo -e "${BLUE}Please enter your subscription ID:${NC}"
    read -p "Subscription ID: " SUBSCRIPTION_ID

    if [ -z "$SUBSCRIPTION_ID" ]; then
        echo -e "${RED}❌ Subscription ID is required.${NC}"
        exit 1
    fi
fi

# Validate subscription ID
if ! az account show --subscription "$SUBSCRIPTION_ID" &> /dev/null; then
    echo -e "${RED}❌ Invalid subscription ID or no access to subscription: $SUBSCRIPTION_ID${NC}"
    exit 1
fi

# Build the scope
if [ -z "$RESOURCE_GROUP" ]; then
    SCOPE="/subscriptions/$SUBSCRIPTION_ID"
    echo -e "${YELLOW}📋 Creating service principal with subscription scope${NC}"
else
    SCOPE="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP"
    echo -e "${YELLOW}📋 Creating service principal with resource group scope${NC}"
fi

echo -e "${BLUE}Service Principal Name: $SP_NAME${NC}"
echo -e "${BLUE}Role: $ROLE${NC}"
echo -e "${BLUE}Scope: $SCOPE${NC}"
echo ""

# Confirm before creating
echo -e "${YELLOW}⚠️  This will create a new service principal. Continue? (y/N)${NC}"
read -p "Continue? " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Operation cancelled.${NC}"
    exit 0
fi

# Create the service principal
echo -e "${YELLOW}🚀 Creating service principal...${NC}"
SP_OUTPUT=$(az ad sp create-for-rbac \
    --name "$SP_NAME" \
    --role "$ROLE" \
    --scopes "$SCOPE" \
    --output json)

# Check if creation was successful
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Service principal created successfully!${NC}"

    # Save to file
    echo "$SP_OUTPUT" > "$OUTPUT_FILE"
    echo -e "${GREEN}📄 Credentials saved to: $OUTPUT_FILE${NC}"

    # Display the credentials
    echo ""
    echo -e "${BLUE}📋 Service Principal Details:${NC}"
    echo "$SP_OUTPUT" | jq -r '.'

    # Extract values for easy copying
    CLIENT_ID=$(echo "$SP_OUTPUT" | jq -r '.appId')
    CLIENT_SECRET=$(echo "$SP_OUTPUT" | jq -r '.password')
    TENANT_ID=$(echo "$SP_OUTPUT" | jq -r '.tenant')

    echo ""
    echo -e "${GREEN}🔧 Next Steps:${NC}"
    echo "1. Copy these values to your .env file:"
    echo ""
    echo -e "${YELLOW}AZURE_CLIENT_ID=$CLIENT_ID${NC}"
    echo -e "${YELLOW}AZURE_CLIENT_SECRET=$CLIENT_SECRET${NC}"
    echo -e "${YELLOW}AZURE_TENANT_ID=$TENANT_ID${NC}"
    echo -e "${YELLOW}AZURE_SUBSCRIPTION_ID=$SUBSCRIPTION_ID${NC}"
    echo ""
    echo "2. Use the login script in the dev container:"
    echo "   ./login-with-sp.sh"
    echo ""
    echo -e "${RED}⚠️  IMPORTANT: Save the client secret now - it won't be shown again!${NC}"

else
    echo -e "${RED}❌ Failed to create service principal.${NC}"
    exit 1
fi
