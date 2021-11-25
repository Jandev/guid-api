var systemName = 'guidapi'
@allowed([
  'dev'
  'test'
  'acc'
  'prod'
])
param environmentName string = 'prod'
param azureRegion string = 'weu'

var webAppName = '${systemName}-${environmentName}-${azureRegion}-app'

module  webApiStorageAccount 'Storage/storageAccounts.bicep' = {
  name: 'storageAccountAppDeploy'
  params: {
    environmentName: environmentName
    systemName: systemName
    azureRegion: azureRegion
  }
}

module applicationInsights 'Insights/components.bicep' = {
  name: 'applicationInsightsDeploy'
  params: {
    environmentName: environmentName
    systemName: systemName
    azureRegion: azureRegion
  }
}

module appServicePlanModule 'Web/serverfarms.bicep' = {
  dependsOn: [
  ]
  name: 'appServicePlanModule'
  params: {
    environmentName: environmentName
    systemName: systemName
    azureRegion: azureRegion
    kind: 'linux'
  }
}

module functionAppModule 'Web/functions.bicep' = {
  dependsOn: [
    appServicePlanModule
    webApiStorageAccount
  ]
  name: 'functionAppModule'
  params: {
    environmentName: environmentName
    systemName: systemName
    azureRegion: azureRegion
    appServicePlanId: appServicePlanModule.outputs.id
  }
}

resource config 'Microsoft.Web/sites/config@2020-12-01' = {
  dependsOn: [
    functionAppModule
  ]
  name: '${webAppName}/web'
  properties: {
    appSettings: [
      {
        name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        value: applicationInsights.outputs.instrumentationKey
      }
      {
        name: 'FUNCTIONS_EXTENSION_VERSION'
        value: '~3'
      }
      {
        name: 'FUNCTIONS_WORKER_RUNTIME'
        value: 'dotnet'
      }
      {
        name: 'WEBSITE_CONTENTSHARE'
        value: 'azure-function'
      }
      {
        name: 'AzureWebJobsStorage'
        value: webApiStorageAccount.outputs.connectionString
      }
      {
        name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
        value: webApiStorageAccount.outputs.connectionString
      }
    ]
  }
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
