# GitHub Repository Setup for Azure Static Web Apps

This document explains how to configure GitHub secrets and variables required for the automated CI/CD pipeline.

## 🔐 Required GitHub Secrets

### 1. Azure Service Principal (`AZURE_CREDENTIALS`)

Create an Azure Service Principal with Contributor permissions:

```bash
# Create service principal
az ad sp create-for-rbac \
  --name "github-actions-guid-api" \
  --role "Contributor" \
  --scopes "/subscriptions/{subscription-id}/resourceGroups/{resource-group-name}" \
  --sdk-auth

# Output will look like:
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

Add the entire JSON output as the `AZURE_CREDENTIALS` secret in GitHub.

### 2. Azure Subscription ID (`AZURE_SUBSCRIPTION_ID`)

```bash
# Get your subscription ID
az account show --query id --output tsv
```

Add this value as the `AZURE_SUBSCRIPTION_ID` secret.

### 3. Static Web App API Token (`AZURE_STATIC_WEB_APPS_API_TOKEN`)

This will be automatically retrieved by the workflow after infrastructure deployment. However, for initial deployments or manual setup:

```bash
# Get the API token after Static Web App is created
az staticwebapp secrets list \
  --name "your-static-web-app-name" \
  --resource-group "your-resource-group" \
  --query "properties.apiKey" \
  --output tsv
```

## 📋 Optional GitHub Variables

These variables have defaults but can be customized:

| Variable | Default | Description |
|----------|---------|-------------|
| `AZURE_RESOURCE_GROUP` | `rg-guid-api` | Azure resource group name |
| `AZURE_STATIC_WEB_APP_NAME` | `guid-api-swa` | Static Web App name |
| `AZURE_LOCATION` | `eastus2` | Azure region |

## 🛠️ Setup Instructions

### Step 1: Create Azure Resources

First, ensure you have a resource group:

```bash
# Create resource group (if it doesn't exist)
az group create \
  --name "rg-guid-api" \
  --location "eastus2"
```

### Step 2: Configure GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Add the following secrets:

   - **`AZURE_CREDENTIALS`**: Service principal JSON (from Step 1 above)
   - **`AZURE_SUBSCRIPTION_ID`**: Your Azure subscription ID

### Step 3: Configure GitHub Variables (Optional)

In the same **Actions** section, under the **Variables** tab, optionally add:

- **`AZURE_RESOURCE_GROUP`**: Custom resource group name
- **`AZURE_STATIC_WEB_APP_NAME`**: Custom Static Web App name  
- **`AZURE_LOCATION`**: Custom Azure region

### Step 4: Initial Deployment

The workflow will automatically:

1. **Deploy Infrastructure**: Create the Static Web App using Bicep template
2. **Get Deployment Token**: Retrieve the API token from the deployed resource
3. **Deploy Application**: Build and deploy your app code
4. **Configure Environment**: Set up staging environments for PRs

## 🔄 Workflow Behavior

### On Push to Main Branch

1. Deploys/updates Azure infrastructure
2. Builds and deploys application to production
3. Updates Static Web App with latest code

### On Pull Request

1. Deploys/updates Azure infrastructure  
2. Creates a staging environment
3. Deploys PR changes to staging URL
4. Provides preview URL in PR comments

### On PR Close/Merge

1. Removes staging environment
2. Cleans up preview resources

## 🧪 Testing the Setup

1. **Push to main branch** to trigger full deployment
2. **Create a pull request** to test staging environment creation
3. **Check GitHub Actions** logs for any issues

### Verification Commands

```bash
# Check if Static Web App was created
az staticwebapp list --output table

# Get the app URL
az staticwebapp show \
  --name "your-app-name" \
  --resource-group "your-resource-group" \
  --query "defaultHostname" \
  --output tsv

# Check deployment status
az staticwebapp show \
  --name "your-app-name" \
  --resource-group "your-resource-group" \
  --query "repositoryUrl"
```

## 🔍 Troubleshooting

### Common Issues

1. **Authentication Errors**
   - Verify `AZURE_CREDENTIALS` secret is correctly formatted JSON
   - Ensure service principal has proper permissions
   - Check subscription ID is correct

2. **Resource Group Not Found**
   - Verify resource group exists in the specified subscription
   - Check `AZURE_RESOURCE_GROUP` variable/default value

3. **Bicep Deployment Failures**
   - Review GitHub Actions logs for specific error messages
   - Verify Bicep template syntax
   - Check Azure resource quotas and limits

4. **Build Failures**
   - Ensure `package.json` exists in repository root
   - Verify build scripts are correctly configured
   - Check Node.js version compatibility

### Getting Help

- **GitHub Actions Logs**: Check the detailed logs in Actions tab
- **Azure Portal**: Monitor resource deployment status
- **Azure CLI**: Use commands above to verify resource state

## 🔒 Security Best Practices

1. **Rotate secrets regularly**: Update service principal credentials periodically
2. **Minimal permissions**: Service principal should only have necessary permissions
3. **Monitor access**: Review GitHub Actions logs for unusual activity
4. **Environment separation**: Use different resource groups for prod/dev

---

**Note**: Keep all secrets secure and never commit them to your repository. Use GitHub's encrypted secrets storage for all sensitive information.