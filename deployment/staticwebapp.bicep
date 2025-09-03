@description('The name of the static web app')
param staticWebAppName string = 'guid-api-swa'

@description('Location for all resources')
param location string = resourceGroup().location

@description('The repository URL')
param repositoryUrl string = ''

@description('The repository token for GitHub Actions')
@secure()
param repositoryToken string = ''

@description('The branch name to deploy from')
param branch string = 'main'

@description('The SKU name for the static web app')
@allowed([
  'Free'
  'Standard'
])
param sku string = 'Free'

@description('Tags to apply to all resources')
param tags object = {
  Environment: 'Dev'
  Project: 'GUID-API'
  Application: 'Static Web App'
}

@description('Whether staging environments are allowed')
@allowed([
  'Enabled'
  'Disabled'
])
param stagingEnvironmentPolicy string = 'Enabled'

@description('Build properties for the static site')
param buildProperties object = {
  appLocation: '/src'
  apiLocation: '/api'
  outputLocation: '/dist'
  skipGithubActionWorkflowGeneration: false
}

@description('App settings for the static web app')
param appSettings object = {
  FUNCTIONS_WORKER_RUNTIME: 'dotnet-isolated'
  FUNCTIONS_EXTENSION_VERSION: '~4'
}

@description('Function app settings for the API')
param functionAppSettings object = {
  FUNCTIONS_WORKER_RUNTIME: 'dotnet-isolated'
  FUNCTIONS_EXTENSION_VERSION: '~4'
  DOTNET_FRAMEWORK_VERSION: 'v8.0'
}

// Create the Static Web App
resource staticWebApp 'Microsoft.Web/staticSites@2024-04-01' = {
  name: staticWebAppName
  location: location
  tags: tags
  sku: {
    name: sku
    tier: sku
  }
  properties: {
    repositoryUrl: repositoryUrl
    repositoryToken: repositoryToken
    branch: branch
    buildProperties: buildProperties
    stagingEnvironmentPolicy: stagingEnvironmentPolicy
    allowConfigFileUpdates: true
    enterpriseGradeCdnStatus: 'Disabled'
    publicNetworkAccess: 'Enabled'
    provider: 'GitHub'
  }
}

// Configure app settings for the static web app
resource staticWebAppSettings 'Microsoft.Web/staticSites/config@2022-03-01' = {
  parent: staticWebApp
  name: 'appsettings'
  properties: appSettings
}

// Configure function app settings for the API
resource staticWebAppFunctionSettings 'Microsoft.Web/staticSites/config@2022-03-01' = {
  parent: staticWebApp
  name: 'functionappsettings'
  properties: functionAppSettings
}

@description('The resource ID of the static web app')
output staticWebAppId string = staticWebApp.id

@description('The name of the static web app')
output staticWebAppName string = staticWebApp.name

@description('The default hostname of the static web app')
output defaultHostname string = staticWebApp.properties.defaultHostname

@description('The repository URL')
output repositoryUrl string = staticWebApp.properties.repositoryUrl

@description('The resource group name')
output resourceGroupName string = resourceGroup().name

@description('The location where the resources were deployed')
output location string = location

@description('The custom domains associated with the static web app')
output customDomains array = staticWebApp.properties.customDomains

@description('The content distribution endpoint for the static site')
output contentDistributionEndpoint string = staticWebApp.properties.contentDistributionEndpoint

@description('Deployment instructions')
output deploymentInstructions string = '''
To deploy this Static Web App:

1. Set the required parameters:
   - staticWebAppName: Name for your static web app (default: guid-api-swa)
   - repositoryUrl: Your GitHub repository URL
   - repositoryToken: GitHub Personal Access Token with repo permissions
   - branch: Git branch to deploy from (default: main)

2. Deploy using Azure CLI:
   az deployment group create --resource-group <your-resource-group> --template-file staticwebapp.bicep --parameters repositoryUrl=<your-repo-url> repositoryToken=<your-token>

3. Or deploy using Azure PowerShell:
   New-AzResourceGroupDeployment -ResourceGroupName <your-resource-group> -TemplateFile staticwebapp.bicep -repositoryUrl <your-repo-url> -repositoryToken <your-token>

4. The deployment will:
   - Create the Azure Static Web App resource
   - Configure build properties for Vite frontend (/src -> /dist)
   - Configure .NET 8 Azure Functions API (/api)
   - Set up GitHub Actions workflow automatically
   - Configure app settings for proper runtime

Note: Make sure your repository structure matches:
- Frontend source: /src
- API source: /api  
- Build output: /dist
'''
