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
param sku string = 'Standard'

@description('Custom domain name for the static web app')
param customDomainName string = 'guid.codes'

@description('Whether to configure custom domain')
param enableCustomDomain bool = true

@description('Custom domain validation method')
@allowed([
  'cname-delegation'
  'dns-txt-token'
])
param validationMethod string = 'cname-delegation'

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

// Configure custom domain (requires Standard SKU)
resource staticWebAppCustomDomain 'Microsoft.Web/staticSites/customDomains@2022-03-01' = if (enableCustomDomain && sku == 'Standard') {
  parent: staticWebApp
  name: customDomainName
  properties: {
    validationMethod: validationMethod
  }
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

@description('Custom domain configuration')
output customDomain object = enableCustomDomain && sku == 'Standard' ? {
  domainName: customDomainName
  validationMethod: validationMethod
  status: 'Configured (check Azure portal for status)'
} : {
  domainName: 'Not configured (requires Standard SKU)'
  validationMethod: 'N/A'
  status: 'Not configured'
}

@description('DNS configuration instructions')
output dnsInstructions string = enableCustomDomain && sku == 'Standard' ? 'Create a CNAME record: ${customDomainName} -> ${staticWebApp.properties.defaultHostname}' : 'Custom domain not configured (requires Standard SKU and enableCustomDomain=true)'

@description('Deployment instructions')
output deploymentInstructions string = '''
To deploy this Static Web App with custom domain:

1. Set the required parameters:
   - staticWebAppName: Name for your static web app (default: guid-api-swa)
   - repositoryUrl: Your GitHub repository URL
   - repositoryToken: GitHub Personal Access Token with repo permissions
   - branch: Git branch to deploy from (default: main)
   - sku: Use "Standard" for custom domain support
   - customDomainName: Your custom domain (e.g., guid.codes)
   - enableCustomDomain: Set to true to configure custom domain

2. Deploy using Azure CLI:
   az deployment group create --resource-group <your-resource-group> --template-file staticwebapp.bicep --parameters repositoryUrl=<your-repo-url> repositoryToken=<your-token> sku=Standard customDomainName=guid.codes

3. Configure DNS:
   - For CNAME delegation: Create CNAME record pointing your domain to the default hostname
   - For TXT validation: Create TXT record with the validation token

4. The deployment will:
   - Create the Azure Static Web App resource (Standard SKU)
   - Configure build properties for Vite frontend (/src -> /dist)
   - Configure .NET 8 Azure Functions API (/api)
   - Set up custom domain (guid.codes)
   - Configure SSL certificate automatically
   - Set up GitHub Actions workflow automatically

Note: Custom domains require Standard SKU and proper DNS configuration.
'''
