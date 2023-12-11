@allowed([
  'dev'
  'tst'
  'acc'
  'prd'
])
param environmentName string = 'prd'

var systemName = 'jvguidapi'
var fullSystemPrefix = '${systemName}-${environmentName}'
var regionWestEuropeName = 'weu'

targetScope = 'subscription'

resource rgWestEurope 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${fullSystemPrefix}-${regionWestEuropeName}'
  location: 'westeurope'
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
