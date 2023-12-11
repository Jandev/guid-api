@allowed([
  'dev'
  'tst'
  'acc'
  'prd'
])
param environmentName string = 'prd'

param bringYourOwnInsightsIdentifier string = ''

var systemName = 'jvguidapi'
var fullSystemPrefix = '${systemName}-${environmentName}'
var regionWestEuropeName = 'weu'
var regionWestUsName = 'wus'
var regionAustraliaSouthEastName = 'aus'

var location = {
  westEurope: 'westeurope'
  westUs: 'westus'
  australiaSouthEast: 'australiasoutheast'
}

targetScope = 'subscription'

resource rgInfrastructure 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${fullSystemPrefix}-infra'
  location: location.westEurope
}

resource rgWestEurope 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${fullSystemPrefix}-${regionWestEuropeName}'
  location: location.westEurope
}

resource rgWestUs 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${fullSystemPrefix}-${regionWestUsName}'
  location: location.westUs
}

resource rgAustraliaSouthEast 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${fullSystemPrefix}-${regionAustraliaSouthEastName}'
  location: location.australiaSouthEast
}

module applicationWestEurope 'application-infrastructure.bicep' = {
  name: 'guidApiWestEurope'
  params: {
    azureRegion: regionWestEuropeName
    environmentName: environmentName
    systemName: systemName
    bringYourOwnInsightsIdentifier: bringYourOwnInsightsIdentifier
  }
  scope: rgWestEurope
}

module applicationWestUs 'application-infrastructure.bicep' = {
  name: 'guidApiWestUs'
  params: {
    azureRegion: regionWestUsName
    environmentName: environmentName
    systemName: systemName
    bringYourOwnInsightsIdentifier: bringYourOwnInsightsIdentifier
  }
  scope: rgWestUs
}

module applicationAustraliaSouthEast 'application-infrastructure.bicep' = {
  name: 'guidApiAustraliaSouthEast'
  params: {
    azureRegion: regionAustraliaSouthEastName
    environmentName: environmentName
    systemName: systemName
    bringYourOwnInsightsIdentifier: bringYourOwnInsightsIdentifier
  }
  scope: rgAustraliaSouthEast
}

module trafficManagerProfile 'Network/trafficManagerProfiles.bicep' = {
  name: 'trafficManagerProfileModule'
  params: {
    environmentName: environmentName
    systemName: systemName
  }
  scope: rgInfrastructure
}

module endpoints 'Network/trafficManagerProfilesEndpoint.bicep' = {
  name: 'trafficManagerProfileEndpoints'
  dependsOn: [
    trafficManagerProfile
    applicationAustraliaSouthEast
    applicationWestEurope
    applicationWestUs
  ]
  params: {
    trafficManagerProfileName: trafficManagerProfile.outputs.instanceName
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
