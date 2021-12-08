param systemName string
@allowed([
  'dev'
  'test'
  'acc'
  'prod'
])
param environmentName string
param azureRegion string

param appServicePlanId string

var webAppName = toLower('${systemName}-${environmentName}-${azureRegion}-app')

resource webApp 'Microsoft.Web/sites@2020-12-01' = {
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
      linuxFxVersion: 'DOTNET|3.1'
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}
resource webAppNewCname 'Microsoft.Web/sites/hostNameBindings@2021-02-01' = {
  name: '${webAppName}/new.guid.codes'
  dependsOn: [
    webApp
  ]
  properties: {
    customHostNameDnsRecordType: 'CName'
    siteName: 'new.guid.codes'
    hostNameType: 'Verified'
    sslState: 'Disabled'
  }
}
resource webApiNewCname 'Microsoft.Web/sites/hostNameBindings@2021-02-01' = {
  name: '${webAppName}/api.guid.codes'
  dependsOn: [
    webAppNewCname
  ]
  properties: {
    customHostNameDnsRecordType: 'CName'
    siteName: 'api.guid.codes'
    hostNameType: 'Verified'
    sslState: 'Disabled'
  }
}

output servicePrincipal string = webApp.identity.principalId
output webAppName string = webAppName
