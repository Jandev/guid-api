# Azure Static Web App Deployment

This folder contains Infrastructure as Code (IaC) templates and deployment scripts for deploying the GUID API as an Azure Static Web App.

## 📁 Files Overview

| File | Description |
|------|-------------|
| `staticwebapp.bicep` | Main Bicep template for Azure Static Web App |
| `staticwebapp.parameters.json` | Parameters file with default values |
| `deploy-staticwebapp.ps1` | PowerShell deployment script |
| `deploy-staticwebapp.sh` | Bash deployment script |
| `README.md` | This documentation file |

## 🏗️ Architecture

The deployment creates:

- **Azure Static Web App** with the following configuration:
  - Frontend: Vite TypeScript application (`/src` → `/dist`)
  - API: .NET 8 Azure Functions (`/api`)
  - GitHub Actions workflow for CI/CD
  - Free or Standard tier options

## 📋 Prerequisites

1. **Azure CLI** installed and configured
   ```bash
   # Install Azure CLI (if not already installed)
   # Windows: winget install Microsoft.AzureCLI
   # macOS: brew install azure-cli
   # Linux: curl -sL https://aka.ms/InstallAzureCLI | sudo bash
   
   # Login to Azure
   az login
   ```

2. **GitHub Repository** with:
   - Source code following Azure Static Web Apps structure:
     - `/src/` - Frontend source code
     - `/api/` - Azure Functions API code
     - `/dist/` - Build output directory (created by build)

3. **GitHub Personal Access Token** with `repo` permissions:
   - Go to GitHub → Settings → Developer settings → Personal access tokens
   - Generate new token with `repo` scope
   - Copy the token (you'll need it for deployment)

## 🚀 Quick Deployment

### Option 1: PowerShell Script (Windows)

```powershell
# Navigate to deployment folder
cd deployment

# Run deployment script
.\deploy-staticwebapp.ps1 `
  -ResourceGroupName "my-resource-group" `
  -RepositoryUrl "https://github.com/your-username/guid-api" `
  -GitHubToken "ghp_your_github_token_here" `
  -StaticWebAppName "my-guid-api" `
  -Location "East US 2"
```

### Option 2: Bash Script (Linux/macOS/WSL)

```bash
# Navigate to deployment folder
cd deployment

# Make script executable
chmod +x deploy-staticwebapp.sh

# Run deployment script
./deploy-staticwebapp.sh \
  --resource-group "my-resource-group" \
  --repository-url "https://github.com/your-username/guid-api" \
  --token "ghp_your_github_token_here" \
  --name "my-guid-api" \
  --location "eastus2"
```

### Option 3: Manual Azure CLI Deployment

```bash
# Create resource group (if it doesn't exist)
az group create --name "my-resource-group" --location "eastus2"

# Deploy the Bicep template
az deployment group create \
  --resource-group "my-resource-group" \
  --template-file staticwebapp.bicep \
  --parameters \
    staticWebAppName="my-guid-api" \
    repositoryUrl="https://github.com/your-username/guid-api" \
    repositoryToken="ghp_your_github_token_here" \
    branch="main"
```

## ⚙️ Configuration Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `staticWebAppName` | No | `"guid-api-swa"` | Name of the Static Web App |
| `location` | No | `resourceGroup().location` | Azure region |
| `repositoryUrl` | Yes | - | GitHub repository URL |
| `repositoryToken` | Yes | - | GitHub Personal Access Token |
| `branch` | No | `"main"` | Git branch to deploy |
| `sku` | No | `"Free"` | Pricing tier (Free/Standard) |
| `stagingEnvironmentPolicy` | No | `"Enabled"` | Allow staging environments |

### Build Properties

The template automatically configures:

```json
{
  "appLocation": "/src",      // Frontend source location
  "apiLocation": "/api",      // API source location  
  "outputLocation": "/dist",  // Build output location
  "appBuildCommand": "npm run build",
  "apiBuildCommand": "dotnet publish -c Release -o bin/Release/net8.0"
}
```

## 🔧 Advanced Configuration

### Custom Parameters File

1. Copy and modify `staticwebapp.parameters.json`:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "staticWebAppName": {
      "value": "my-custom-swa-name"
    },
    "sku": {
      "value": "Standard"
    },
    "tags": {
      "value": {
        "Environment": "Production",
        "Owner": "MyTeam"
      }
    }
  }
}
```

2. Deploy with custom parameters:

```bash
az deployment group create \
  --resource-group "my-resource-group" \
  --template-file staticwebapp.bicep \
  --parameters @staticwebapp.parameters.json \
  --parameters repositoryToken="ghp_your_token"
```

### Standard Tier Features

When using `sku: "Standard"`, you get:

- Custom domains
- Private endpoints
- Staging environments
- Enhanced security features
- SLA guarantees

## 📊 Post-Deployment

After successful deployment:

1. **GitHub Actions Workflow** is automatically created in your repository
2. **Automatic Deployment** triggers on pushes to the specified branch
3. **Static Web App URL** is provided in the deployment output
4. **API endpoints** are available at `https://your-app.azurestaticapps.net/api/`

### Monitoring Deployment

```bash
# Check deployment status
az staticwebapp show \
  --name "your-app-name" \
  --resource-group "your-resource-group"

# View GitHub Actions runs
# (Go to your GitHub repository → Actions tab)
```

## 🔍 Troubleshooting

### Common Issues

1. **GitHub Token Permissions**
   - Ensure token has `repo` scope
   - Token must not be expired
   - Repository must be accessible with the token

2. **Build Failures**
   - Check GitHub Actions logs in your repository
   - Verify folder structure matches `buildProperties`
   - Ensure `package.json` and build scripts are correct

3. **API Not Working**
   - Verify `.NET 8` runtime configuration
   - Check Function App settings
   - Review Azure Functions logs in portal

### Getting Help

```bash
# Check Azure CLI version
az version

# View deployment logs
az deployment group show \
  --resource-group "your-resource-group" \
  --name "your-deployment-name"

# List Static Web Apps
az staticwebapp list --output table
```

## 🧹 Cleanup

To remove all resources:

```bash
# Delete the Static Web App
az staticwebapp delete \
  --name "your-app-name" \
  --resource-group "your-resource-group"

# Or delete entire resource group (if dedicated to this app)
az group delete --name "your-resource-group" --yes --no-wait
```

## 📚 Additional Resources

- [Azure Static Web Apps Documentation](https://docs.microsoft.com/en-us/azure/static-web-apps/)
- [Bicep Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [GitHub Actions for Azure](https://docs.microsoft.com/en-us/azure/developer/github/github-actions)
- [Azure Functions with .NET 8](https://docs.microsoft.com/en-us/azure/azure-functions/dotnet-isolated-process-guide)

---

**Note**: Remember to keep your GitHub Personal Access Token secure and never commit it to your repository. Use Azure Key Vault or GitHub Secrets for production deployments.