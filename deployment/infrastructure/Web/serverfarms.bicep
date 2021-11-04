param systemName string
@allowed([
  'dev'
  'test'
  'acc'
  'prod'
])
param environmentName string
param azureRegion string

@allowed([
  'functionapp'
  'linux'
  'app'
])
param kind string = 'app'

param sku object = {
  name: 'Y'
}

var servicePlanName = toLower('${systemName}-${environmentName}-${azureRegion}-plan')

resource appFarm 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: servicePlanName
  location: resourceGroup().location
  kind: kind
  sku: {
    name: sku.name
  }
}

output servicePlanName string = servicePlanName
output id string = appFarm.id
