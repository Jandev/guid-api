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
@allowed([
  'app'
  'functionapp'
])
param kind string = 'app'

var webAppName = toLower('${systemName}-${environmentName}-${azureRegion}-app')

resource webApp 'Microsoft.Web/sites@2020-12-01' = {
  name: webAppName
  location: resourceGroup().location
  kind: kind
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    clientAffinityEnabled: false
    siteConfig: {
      ftpsState: 'Disabled'
      http20Enabled: true
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

output servicePrincipal string = webApp.identity.principalId
output webAppName string = webAppName
