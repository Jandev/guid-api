@allowed([
  'dev'
  'test'
  'acc'
  'prod'
])
param environmentName string
param azureRegion string
param systemName string

module  webApiStorageAccount 'Storage/storageAccounts.bicep' = {
  name: 'storageAccountAppDeploy'
  params: {
    environmentName: environmentName
    systemName: '${systemName}static'
    azureRegion: azureRegion
  }
}
