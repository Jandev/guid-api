#!/bin/bash

# Azure Static Web App Deployment Script (Bash)
# This script deploys the GUID API Static Web App to Azure using Azure CLI

set -e

# Default values
DEFAULT_LOCATION="eastus2"
DEFAULT_BRANCH="main"
DEFAULT_SKU="Free"
DEFAULT_SWA_NAME="guid-api-swa"

# Function to show usage
usage() {
    echo "Usage: $0 -g <resource-group> -r <repository-url> -t <github-token> [options]"
    echo ""
    echo "Required parameters:"
    echo "  -g, --resource-group    Azure resource group name"
    echo "  -r, --repository-url    GitHub repository URL"
    echo "  -t, --token            GitHub Personal Access Token"
    echo ""
    echo "Optional parameters:"
    echo "  -n, --name             Static Web App name (default: $DEFAULT_SWA_NAME)"
    echo "  -l, --location         Azure region (default: $DEFAULT_LOCATION)"
    echo "  -b, --branch           Git branch to deploy (default: $DEFAULT_BRANCH)"
    echo "  -s, --sku              SKU (Free or Standard, default: $DEFAULT_SKU)"
    echo "  --subscription         Azure subscription ID"
    echo "  -h, --help             Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 -g my-resource-group -r https://github.com/user/guid-api -t ghp_xxxxxxxxxxxx"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -g|--resource-group)
            RESOURCE_GROUP="$2"
            shift 2
            ;;
        -r|--repository-url)
            REPOSITORY_URL="$2"
            shift 2
            ;;
        -t|--token)
            GITHUB_TOKEN="$2"
            shift 2
            ;;
        -n|--name)
            SWA_NAME="$2"
            shift 2
            ;;
        -l|--location)
            LOCATION="$2"
            shift 2
            ;;
        -b|--branch)
            BRANCH="$2"
            shift 2
            ;;
        -s|--sku)
            SKU="$2"
            shift 2
            ;;
        --subscription)
            SUBSCRIPTION_ID="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown parameter: $1"
            usage
            exit 1
            ;;
    esac
done

# Set defaults for optional parameters
SWA_NAME="${SWA_NAME:-$DEFAULT_SWA_NAME}"
LOCATION="${LOCATION:-$DEFAULT_LOCATION}"
BRANCH="${BRANCH:-$DEFAULT_BRANCH}"
SKU="${SKU:-$DEFAULT_SKU}"

# Validate required parameters
if [[ -z "$RESOURCE_GROUP" || -z "$REPOSITORY_URL" || -z "$GITHUB_TOKEN" ]]; then
    echo "❌ Error: Missing required parameters"
    echo ""
    usage
    exit 1
fi

echo "🚀 Starting Azure Static Web App deployment..."

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed. Please install it first."
    exit 1
fi

echo "✅ Azure CLI detected"

# Check login status
if ! az account show &> /dev/null; then
    echo "❌ Not logged in to Azure. Please run 'az login' first."
    exit 1
fi

CURRENT_USER=$(az account show --query user.name -o tsv)
echo "✅ Logged in as: $CURRENT_USER"

# Set subscription if provided
if [[ -n "$SUBSCRIPTION_ID" ]]; then
    echo "🔄 Switching to subscription: $SUBSCRIPTION_ID"
    az account set --subscription "$SUBSCRIPTION_ID"
fi

CURRENT_SUB=$(az account show --query name -o tsv)
CURRENT_SUB_ID=$(az account show --query id -o tsv)
echo "📋 Using subscription: $CURRENT_SUB ($CURRENT_SUB_ID)"

# Check if resource group exists
echo "🔍 Checking resource group: $RESOURCE_GROUP"
if ! az group exists --name "$RESOURCE_GROUP" --output tsv | grep -q "true"; then
    echo "📦 Resource group will be created by Bicep template"
else
    echo "✅ Resource group already exists and will be updated"
fi

# Get script directory to find Bicep file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BICEP_FILE="$SCRIPT_DIR/staticwebapp.bicep"

if [[ ! -f "$BICEP_FILE" ]]; then
    echo "❌ Bicep file not found at: $BICEP_FILE"
    exit 1
fi

echo ""
echo "📋 Deployment Parameters:"
echo "   - Static Web App Name: $SWA_NAME"
echo "   - Location: $LOCATION"
echo "   - Repository URL: $REPOSITORY_URL"
echo "   - Branch: $BRANCH"
echo "   - SKU: $SKU"
echo "   - GitHub Token: [PROTECTED]"

echo ""
echo "🚀 Starting deployment..."

# Generate deployment name
DEPLOYMENT_NAME="staticwebapp-deployment-$(date +%Y%m%d-%H%M%S)"

# Deploy the Bicep template
echo "⏳ Deploying Bicep template..."

DEPLOYMENT_OUTPUT=$(az deployment sub create \
    --name "$DEPLOYMENT_NAME" \
    --location "$LOCATION" \
    --template-file "$BICEP_FILE" \
    --parameters \
        resourceGroupName="$RESOURCE_GROUP" \
        staticWebAppName="$SWA_NAME" \
        location="$LOCATION" \
        repositoryUrl="$REPOSITORY_URL" \
        repositoryToken="$GITHUB_TOKEN" \
        branch="$BRANCH" \
        sku="$SKU" \
    --output json)

if [[ $? -ne 0 ]]; then
    echo "❌ Deployment failed"
    exit 1
fi

echo "✅ Deployment completed successfully!"

# Extract and display outputs
echo ""
echo "📋 Deployment Outputs:"

DEFAULT_HOSTNAME=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.properties.outputs.defaultHostname.value')
SWA_ID=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.properties.outputs.staticWebAppId.value')

if [[ "$DEFAULT_HOSTNAME" != "null" && -n "$DEFAULT_HOSTNAME" ]]; then
    echo "   🌐 Default Hostname: https://$DEFAULT_HOSTNAME"
fi

if [[ "$SWA_ID" != "null" && -n "$SWA_ID" ]]; then
    echo "   📋 Static Web App ID: $SWA_ID"
fi

echo ""
echo "🎉 Azure Static Web App deployed successfully!"
echo ""
echo "Next Steps:"
echo "1. 🔄 GitHub Actions workflow will be automatically created in your repository"
echo "2. 🚀 Push code to the '$BRANCH' branch to trigger automatic deployment"
echo "3. 🌐 Your app will be available at the hostname shown above"
echo "4. 📊 Monitor deployment status in the Azure portal"

echo ""
echo "✅ Deployment script completed!"