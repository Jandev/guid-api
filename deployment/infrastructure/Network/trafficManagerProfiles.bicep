param systemName string
@allowed([
  'dev'
  'test'
  'acc'
  'prod'
])
param environmentName string
param relativeLiveEndpoint string = '/api/Live'
param webAppEndpoints array

var trafficManagerProfileName = '${systemName}-${environmentName}'

resource webAppResources 'Microsoft.Web/sites@2021-02-01' existing = [for i in webAppEndpoints: {
  name: i.webAppNameToAdd
  scope: resourceGroup(i.webAppResourceGroupName)
}]


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
    endpoints: [for (webAppEndpoint, index) in webAppEndpoints: {
        id: '${resourceId('Microsoft.Network/trafficmanagerprofiles', trafficManagerProfileName)}/azureEndpoints/${webAppResources[index].name}'
        name: webAppResources[index].name
        type: 'Microsoft.Network/trafficManagerProfiles/azureEndpoints'
        properties: {
          endpointStatus: 'Enabled'
          endpointMonitorStatus: 'Online'
          targetResourceId: webAppResources[index].id
          target: webAppResources[index].properties.hostNames[0]
          endpointLocation: webAppResources[index].location
          weight: 1
          priority: index + 1
        }
      }]
  }
}
