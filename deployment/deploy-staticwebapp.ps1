# Azure Static Web App Deployment Script
# This script deploys the GUID API Static Web App to Azure

param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory = $true)]
    [string]$RepositoryUrl,
    
    [Parameter(Mandatory = $true)]
    [string]$GitHubToken,
    
    [Parameter(Mandatory = $false)]
    [string]$StaticWebAppName = "guid-api-swa",
    
    [Parameter(Mandatory = $false)]
    [string]$Location = "East US 2",
    
    [Parameter(Mandatory = $false)]
    [string]$Branch = "main",
    
    [Parameter(Mandatory = $false)]
    [string]$Sku = "Free",
    
    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId = ""
)

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting Azure Static Web App deployment..." -ForegroundColor Green

# Check if Azure CLI is installed
try {
    $azVersion = az version --output json | ConvertFrom-Json
    Write-Host "✅ Azure CLI version $($azVersion.'azure-cli') detected" -ForegroundColor Green
} catch {
    Write-Error "❌ Azure CLI is not installed or not accessible. Please install Azure CLI first."
    exit 1
}

# Login check
try {
    $account = az account show --output json | ConvertFrom-Json
    Write-Host "✅ Logged in as: $($account.user.name)" -ForegroundColor Green
    
    if ($SubscriptionId -and $account.id -ne $SubscriptionId) {
        Write-Host "🔄 Switching to subscription: $SubscriptionId" -ForegroundColor Yellow
        az account set --subscription $SubscriptionId
    }
    
    $currentSub = az account show --output json | ConvertFrom-Json
    Write-Host "📋 Using subscription: $($currentSub.name) ($($currentSub.id))" -ForegroundColor Cyan
    
} catch {
    Write-Error "❌ Not logged in to Azure. Please run 'az login' first."
    exit 1
}

# Check if resource group exists
Write-Host "🔍 Checking resource group: $ResourceGroupName" -ForegroundColor Yellow
$rgExists = az group exists --name $ResourceGroupName --output tsv

if ($rgExists -eq "false") {
    Write-Host "📦 Creating resource group: $ResourceGroupName in $Location" -ForegroundColor Yellow
    az group create --name $ResourceGroupName --location $Location --output none
    if ($LASTEXITCODE -ne 0) {
        Write-Error "❌ Failed to create resource group"
        exit 1
    }
    Write-Host "✅ Resource group created successfully" -ForegroundColor Green
} else {
    Write-Host "✅ Resource group already exists" -ForegroundColor Green
}

# Prepare deployment parameters
$deploymentParams = @{
    staticWebAppName = $StaticWebAppName
    location = $Location
    repositoryUrl = $RepositoryUrl
    repositoryToken = $GitHubToken
    branch = $Branch
    sku = $Sku
}

# Convert parameters to Azure CLI format
$paramString = ""
foreach ($key in $deploymentParams.Keys) {
    $value = $deploymentParams[$key]
    if ($key -eq "repositoryToken") {
        $paramString += "$key='$value' "
    } else {
        $paramString += "$key='$value' "
    }
}

# Get the script directory to find the Bicep file
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$bicepFile = Join-Path $scriptDir "staticwebapp.bicep"

if (-not (Test-Path $bicepFile)) {
    Write-Error "❌ Bicep file not found at: $bicepFile"
    exit 1
}

Write-Host "📋 Deployment Parameters:" -ForegroundColor Cyan
Write-Host "   - Static Web App Name: $StaticWebAppName" -ForegroundColor White
Write-Host "   - Location: $Location" -ForegroundColor White
Write-Host "   - Repository URL: $RepositoryUrl" -ForegroundColor White
Write-Host "   - Branch: $Branch" -ForegroundColor White
Write-Host "   - SKU: $Sku" -ForegroundColor White
Write-Host "   - GitHub Token: [PROTECTED]" -ForegroundColor White

Write-Host ""
Write-Host "🚀 Starting deployment..." -ForegroundColor Yellow

# Deploy the Bicep template
$deploymentName = "staticwebapp-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

try {
    Write-Host "⏳ Deploying Bicep template..." -ForegroundColor Yellow
    
    $deployment = az deployment group create `
        --resource-group $ResourceGroupName `
        --name $deploymentName `
        --template-file $bicepFile `
        --parameters $paramString.Trim() `
        --output json | ConvertFrom-Json
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "❌ Deployment failed"
        exit 1
    }
    
    Write-Host "✅ Deployment completed successfully!" -ForegroundColor Green
    
    # Extract outputs
    if ($deployment.properties.outputs) {
        Write-Host ""
        Write-Host "📋 Deployment Outputs:" -ForegroundColor Cyan
        
        foreach ($output in $deployment.properties.outputs.PSObject.Properties) {
            $name = $output.Name
            $value = $output.Value.value
            
            if ($name -eq "defaultHostname") {
                Write-Host "   🌐 Default Hostname: https://$value" -ForegroundColor Green
            } elseif ($name -eq "deploymentInstructions") {
                # Skip deployment instructions in output summary
                continue
            } else {
                Write-Host "   📋 $($name): $value" -ForegroundColor White
            }
        }
    }
    
    Write-Host ""
    Write-Host "🎉 Azure Static Web App deployed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Yellow
    Write-Host "1. 🔄 GitHub Actions workflow will be automatically created in your repository" -ForegroundColor White
    Write-Host "2. 🚀 Push code to the '$Branch' branch to trigger automatic deployment" -ForegroundColor White
    Write-Host "3. 🌐 Your app will be available at the hostname shown above" -ForegroundColor White
    Write-Host "4. 📊 Monitor deployment status in the Azure portal" -ForegroundColor White
    
} catch {
    Write-Error "❌ Deployment failed: $($_.Exception.Message)"
    exit 1
}

Write-Host ""
Write-Host "✅ Deployment script completed!" -ForegroundColor Green