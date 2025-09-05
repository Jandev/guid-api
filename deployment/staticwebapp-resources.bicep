@description('The name of the static web app')
param staticWebAppName string

@description('Location for all resources')
param location string

@description('The repository URL - optional for infrastructure-only deployment')
param repositoryUrl string = ''

@description('The repository token for GitHub Actions - optional for infrastructure-only deployment')
@secure()
param repositoryToken string = ''

@description('The branch name to deploy from - optional for infrastructure-only deployment')
param branch string = ''

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
  properties: union(
    {
      buildProperties: buildProperties
      stagingEnvironmentPolicy: stagingEnvironmentPolicy
      allowConfigFileUpdates: true
      enterpriseGradeCdnStatus: 'Disabled'
      publicNetworkAccess: 'Enabled'
    },
    // Only include repository properties if they are provided (not empty)
    !empty(repositoryUrl) ? {
      repositoryUrl: repositoryUrl
      repositoryToken: repositoryToken
      branch: branch
      provider: 'GitHub'
    } : {}
  )
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

// Configure custom domain (now supported on both Free and Standard SKUs)
resource staticWebAppCustomDomain 'Microsoft.Web/staticSites/customDomains@2022-03-01' = if (enableCustomDomain) {
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
output repositoryUrl string = !empty(repositoryUrl) ? staticWebApp.properties.repositoryUrl : ''
