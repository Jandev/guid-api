# GitHub Repository Setup for Azure Static Web Apps

This document explains how to configure GitHub secrets and variables required for the automated CI/CD pipeline.

## 🔐 Required GitHub Secrets

### 1. Azure Service Principal (`AZURE_DEV`)

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

### 3. GitHub Personal Access Token (`DEPLOYMENT_PAT`) ⚠️ **CRITICAL FOR AZURE STATIC WEB APPS**

**Why required**: Azure Static Web Apps needs admin permissions to:
- Create and manage GitHub Actions workflows
- Set up repository webhooks for automated deployments
- Manage deployment keys and secrets
- Configure branch protection rules (if enabled)

The default `GITHUB_TOKEN` has limited permissions and **will cause deployment to fail**.

**How to create**:
1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Set expiration (recommended: 90 days or 1 year)
4. Select required scopes:
   - ✅ `repo` (Full control of private repositories)
   - ✅ `admin:repo_hook` (Full control of repository hooks) 
   - ✅ `workflow` (Update GitHub Action workflows)
5. Click "Generate token"
6. Copy the token and add it as repository secret named `DEPLOYMENT_PAT`

**Alternative - Fine-grained PATs (Beta)**:
1. Go to GitHub Settings → Developer settings → Personal access tokens → Fine-grained tokens
2. Click "Generate new token"
3. Select repository: `Jandev/guid-api`
4. Set repository permissions:
   - ✅ Administration: Read and write
   - ✅ Actions: Write
   - ✅ Contents: Read and write
   - ✅ Metadata: Read
   - ✅ Pull requests: Write

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

   - **`AZURE_DEV`**: Service principal JSON (from Step 1 above)
   - **`AZURE_SUBSCRIPTION_ID`**: Your Azure subscription ID  
   - **`DEPLOYMENT_PAT`**: Personal Access Token with admin permissions (⚠️ **REQUIRED**)

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

1. **"RepositoryToken is invalid" Error** ⚠️
   - **Most Common Cause**: Missing or incorrect `DEPLOYMENT_PAT` secret
   - **Solution**: Create a Personal Access Token with `repo`, `admin:repo_hook`, and `workflow` permissions
   - Verify the token hasn't expired
   - Ensure the token belongs to a user with admin access to the repository

2. **Authentication Errors**
   - Verify `AZURE_DEV` secret is correctly formatted JSON
   - Ensure service principal has proper permissions
   - Check subscription ID is correct

3. **Resource Group Not Found**
   - Verify resource group exists in the specified subscription
   - Check `AZURE_RESOURCE_GROUP` variable/default value

4. **Bicep Deployment Failures**
   - Review GitHub Actions logs for specific error messages
   - Verify Bicep template syntax
   - Check Azure resource quotas and limits

5. **Build Failures**
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