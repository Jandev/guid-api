param systemName string
@allowed([
  'dev'
  'tst'
  'acc'
  'prd'
])
param environmentName string
param azureRegion string

param appServicePlanId string

var webAppName = toLower('${systemName}-${environmentName}-${azureRegion}-app')

var subdomainPrefix = (environmentName == 'prd') ? '' : '${environmentName}.'

resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: webAppName
  location: resourceGroup().location
  kind: 'functionapp,linux'
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    clientAffinityEnabled: false
    siteConfig: {
      ftpsState: 'Disabled'
      http20Enabled: true
      linuxFxVersion: 'DOTNET-ISOLATED|8.0'
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
        {
          name: 'WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED'
          value: '1'
        }
      ]
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}
resource webAppNewCname 'Microsoft.Web/sites/hostNameBindings@2021-02-01' = {
  name: '${webAppName}/${subdomainPrefix}new.guid.codes'
  dependsOn: [
    webApp
  ]
  properties: {
    customHostNameDnsRecordType: 'CName'
    siteName: '${subdomainPrefix}new.guid.codes'
    hostNameType: 'Verified'
    sslState: 'Disabled'
  }
}
resource webApiNewCname 'Microsoft.Web/sites/hostNameBindings@2021-02-01' = {
  name: '${webAppName}/${subdomainPrefix}api.guid.codes'
  dependsOn: [
    webAppNewCname
  ]
  properties: {
    customHostNameDnsRecordType: 'CName'
    siteName: '${subdomainPrefix}api.guid.codes'
    hostNameType: 'Verified'
    sslState: 'Disabled'
  }
}

output servicePrincipal string = webApp.identity.principalId
output webAppName string = webAppName
