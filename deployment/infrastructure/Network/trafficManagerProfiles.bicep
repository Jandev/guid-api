param systemName string
@allowed([
  'dev'
  'test'
  'acc'
  'prod'
])
param environmentName string
param relativeLiveEndpoint string = '/api/Live'
param webAppNameToAdd string
param webAppResourceGroupName string

var trafficManagerProfileName = '${systemName}${environmentName}'

resource webAppResource 'Microsoft.Web/sites@2021-02-01' existing = {
  name: webAppNameToAdd
  scope: resourceGroup(webAppResourceGroupName)
}


resource trafficManagerProfile 'Microsoft.Network/trafficmanagerprofiles@2018-08-01' = {
  name: trafficManagerProfileName
  location: 'global'
  properties: {
    dnsConfig: {
      relativeName: trafficManagerProfileName
      ttl: 60
    }
    profileStatus: 'Enabled'
    trafficRoutingMethod: 'Performance'
    monitorConfig: {
      profileMonitorStatus: 'Online'
      protocol: 'HTTPS'
      port: 443
      path: relativeLiveEndpoint
      timeoutInSeconds: 10
      intervalInSeconds: 30
      toleratedNumberOfFailures: 3
    }
    endpoints: [
      {
        id: '${resourceId('Microsoft.Network/trafficmanagerprofiles', trafficManagerProfileName)}/azureEndpoints/${webAppResource.name}'
        name: webAppResource.name
        type: 'Microsoft.Network/trafficManagerProfiles/azureEndpoints'
        properties: {
          endpointStatus: 'Enabled'
          endpointMonitorStatus: 'Online'
          targetResourceId: webAppResource.id
          target: webAppResource.properties.hostNames[0]
          endpointLocation: webAppResource.location
          weight: 1
          priority: 1
        }
      }
    ]
  }
}
