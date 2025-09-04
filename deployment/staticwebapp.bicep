targetScope = 'subscription'

@description('The name of the resource group')
param resourceGroupName string = 'rg-guid-api'

@description('The name of the static web app')
param staticWebAppName string = 'guid-api-swa'

@description('Location for all resources')
param location string = 'westeurope'

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

@description('Custom domain validation method - Note: Apex domains (like guid.codes) automatically use dns-txt-token regardless of this setting')
@allowed([
  'cname-delegation'
  'dns-txt-token'
])
param validationMethod string = 'dns-txt-token'

// Automatically determine if this is an apex domain (no subdomain)
// Apex domains (like guid.codes) must use dns-txt-token validation
// Subdomains (like www.guid.codes) can use cname-delegation
var isApexDomain = length(split(customDomainName, '.')) == 2
var actualValidationMethod = isApexDomain ? 'dns-txt-token' : validationMethod

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

// Create the resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// Deploy the Static Web App into the resource group
module staticWebAppDeployment 'staticwebapp-resources.bicep' = {
  name: 'staticWebAppDeployment'
  scope: resourceGroup
  params: {
    staticWebAppName: staticWebAppName
    location: location
    repositoryUrl: repositoryUrl
    repositoryToken: repositoryToken
    branch: branch
    sku: sku
    customDomainName: customDomainName
    enableCustomDomain: enableCustomDomain
    validationMethod: actualValidationMethod
    tags: tags
    stagingEnvironmentPolicy: stagingEnvironmentPolicy
    buildProperties: buildProperties
    appSettings: appSettings
    functionAppSettings: functionAppSettings
  }
}

@description('The resource ID of the static web app')
output staticWebAppId string = staticWebAppDeployment.outputs.staticWebAppId

@description('The name of the static web app')
output staticWebAppName string = staticWebAppDeployment.outputs.staticWebAppName

@description('The default hostname of the static web app')
output defaultHostname string = staticWebAppDeployment.outputs.defaultHostname

@description('The repository URL')
output repositoryUrl string = staticWebAppDeployment.outputs.repositoryUrl

@description('The resource group name')
output resourceGroupName string = resourceGroup.name

@description('The location where the resources were deployed')
output location string = location

@description('DNS configuration instructions based on domain type')
output dnsInstructions string = isApexDomain 
  ? 'APEX DOMAIN (${customDomainName}): Create a TXT record with name "@" or "${customDomainName}" and the validation token value from Azure portal. Apex domains must use DNS TXT validation.'
  : 'SUBDOMAIN (${customDomainName}): Create a CNAME record pointing ${customDomainName} to ${staticWebAppDeployment.outputs.defaultHostname}'

@description('Validation method used for custom domain')
output validationMethod string = actualValidationMethod

@description('Domain type detected')
output domainType string = isApexDomain ? 'apex' : 'subdomain'

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
