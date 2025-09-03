@description('The name of the static web app')
param staticWebAppName string

@description('Location for all resources')
param location string

@description('The repository URL')
param repositoryUrl string

@description('The repository token for GitHub Actions')
@secure()
param repositoryToken string

@description('The branch name to deploy from')
param branch string

@description('The SKU name for the static web app')
@allowed([
  'Free'
  'Standard'
])
param sku string

@description('Custom domain name for the static web app')
param customDomainName string

@description('Whether to configure custom domain')
param enableCustomDomain bool

@description('Custom domain validation method')
@allowed([
  'cname-delegation'
  'dns-txt-token'
])
param validationMethod string

@description('Tags to apply to all resources')
param tags object

@description('Whether staging environments are allowed')
@allowed([
  'Enabled'
  'Disabled'
])
param stagingEnvironmentPolicy string

@description('Build properties for the static site')
param buildProperties object

@description('App settings for the static web app')
param appSettings object

@description('Function app settings for the API')
param functionAppSettings object

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
