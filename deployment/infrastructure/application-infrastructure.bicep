@allowed([
  'dev'
  'tst'
  'acc'
  'prd'
])
param environmentName string
param azureRegion string
param systemName string

param bringYourOwnInsightsIdentifier string = ''

var webAppName = '${systemName}-${environmentName}-${azureRegion}-app'

targetScope = 'resourceGroup'

module webApiStorageAccount 'Storage/storageAccounts.bicep' = {
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
    bringYourOwn: bringYourOwnInsightsIdentifier
  }
}

module appServicePlanModule 'Web/serverfarms.bicep' = {
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
    cors: {
      allowedOrigins: [
        'http://127.0.0.1:5500'
        'https://guid.codes'
      ]
    }
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
        name: 'WEBSITE_RUN_FROM_PACKAGE'
        value: '1'
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

output webApplicationName string = functionAppModule.outputs.webAppName
output resourceGroupLocation string = resourceGroup().location
