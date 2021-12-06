@allowed([
  'dev'
  'test'
  'acc'
  'prod'
])
param environmentName string = 'prod'

var systemName = 'guidapi'
var fullSystemPrefix = '${systemName}-${environmentName}'
var regionWestEuropeName = 'weu'
var regionWestUsName = 'wus'
var regionAustraliaSouthEastName = 'aus'

targetScope = 'subscription'

resource rgWestEurope 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${fullSystemPrefix}-${regionWestEuropeName}'
  location: 'westeurope'
}

resource rgWestUs 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${fullSystemPrefix}-${regionWestUsName}'
  location: 'westus'
}

resource rgAustraliaSouthEast 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${fullSystemPrefix}-${regionAustraliaSouthEastName}'
  location: 'australiasoutheast'
}

module applicationWestEurope 'application-infrastructure.bicep' = {
  name: 'guidApiWestEurope'
  params: {
    azureRegion: regionWestEuropeName
    environmentName: environmentName
    systemName: systemName
  }
  scope: rgWestEurope
}

module applicationWestUs 'application-infrastructure.bicep' = {
  name: 'guidApiWestUs'
  params: {
    azureRegion: regionWestUsName
    environmentName: environmentName
    systemName: systemName
  }
  scope: rgWestUs
}

module applicationAustraliaSouthEast 'application-infrastructure.bicep' = {
  name: 'guidApiAustraliaSouthEast'
  params: {
    azureRegion: regionAustraliaSouthEastName
    environmentName: environmentName
    systemName: systemName
  }
  scope: rgAustraliaSouthEast
}

module trafficManagerProfile 'Network/trafficManagerProfiles.bicep' = {
  name: 'trafficManagerProfileModule'
  dependsOn: [
    functionAppModule
  ]
  params: {
    environmentName: environmentName
    systemName: systemName
    webAppNameToAdd: functionAppModule.outputs.webAppName
    webAppResourceGroupName: resourceGroup().name
  }
  scope: resourceGroup('${systemName}-${environmentName}-infra')
}
