param systemName string
@allowed([
  'dev'
  'tst'
  'acc'
  'prd'
])
param environmentName string = 'prd'
param azureRegion string = 'weu'
param bringYourOwn string

var applicationInsightsName = '${systemName}-${environmentName}-${azureRegion}-ai'

resource applicationInsights 'Microsoft.Insights/components@2020-02-02-preview' = if(empty(bringYourOwn)) {
  kind: 'web'
  location: resourceGroup().location
  name: applicationInsightsName
  properties: {
    Application_Type: 'web'
  }
}

output applicationInsightsName string = empty(bringYourOwn) ? applicationInsightsName : reference(bringYourOwn, '2020-02-02').name
output instrumentationKey string = empty(bringYourOwn) ? applicationInsights.properties.InstrumentationKey : reference(bringYourOwn, '2020-02-02').InstrumentationKey
