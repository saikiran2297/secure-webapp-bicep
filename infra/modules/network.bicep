param location string
param projectName string
param tags object

var vnetName = 'vnet-${projectName}'
var snetWebIntegrationName = 'snet-webint-${projectName}'
var snetPrivateEndpointsName = 'snet-pe-${projectName}'

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: { addressPrefixes: ['10.20.0.0/16'] }
    subnets: [
      {
        name: snetWebIntegrationName
        properties: {
          addressPrefix: '10.20.1.0/24'
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: snetPrivateEndpointsName
        properties: {
          addressPrefix: '10.20.2.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

output vnetId string = vnet.id
output snetWebIntegrationId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, snetWebIntegrationName)
output snetPrivateEndpointsId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, snetPrivateEndpointsName)
