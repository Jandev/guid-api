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

resource rgInfrastructure 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${fullSystemPrefix}-infra'
  location: 'westeurope'
}

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
    applicationAustraliaSouthEast
    applicationWestEurope
    applicationWestUs
  ]
  params: {
    environmentName: environmentName
    systemName: systemName
    webAppEndpoints: [
      {
        webAppNameToAdd: applicationAustraliaSouthEast.outputs.webApplicationName
        webAppResourceGroupName: rgAustraliaSouthEast.name
        priority: 1
      }
      {
        webAppNameToAdd: applicationWestEurope.outputs.webApplicationName
        webAppResourceGroupName: rgWestEurope.name
        priority: 2
      }
      {
        webAppNameToAdd: applicationWestUs.outputs.webApplicationName
        webAppResourceGroupName: rgWestUs.name
        priority: 3
      }
    ]
  }
  scope: rgInfrastructure
}

module staticSite 'static-site.bicep' = {
  name: 'staticSite'
  params: {
    azureRegion: regionWestEuropeName
    environmentName: environmentName
    systemName: systemName
  }  
  scope: rgWestEurope
}
