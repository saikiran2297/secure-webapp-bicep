targetScope = 'resourceGroup'

param location string = resourceGroup().location
param projectName string = 'secureweb'
param environment string = 'dev'

// Tags
param tags object = {
  project: projectName
  env: environment
}

// Network
module network 'modules/network.bicep' = {
  name: 'network'
  params: {
    location: location
    projectName: projectName
    tags: tags
  }
}

// Monitoring
module monitoring 'modules/monitoring.bicep' = {
  name: 'monitoring'
  params: {
    location: location
    projectName: projectName
    tags: tags
  }
}

// Key Vault (private endpoint + RBAC)
module keyvault 'modules/keyvault.bicep' = {
  name: 'keyvault'
  params: {
    location: location
    projectName: projectName
    tags: tags
    vnetId: network.outputs.vnetId
    snetPrivateEndpointsId: network.outputs.snetPrivateEndpointsId
  }
}

// Web App (managed identity + vnet integration + KV references)
module webapp 'modules/webapp.bicep' = {
  name: 'webapp'
  params: {
    location: location
    projectName: projectName
    tags: tags

    appInsightsConnectionString: monitoring.outputs.appInsightsConnectionString

    // VNet integration subnet
    snetWebIntegrationId: network.outputs.snetWebIntegrationId

    // Key Vault
    keyVaultName: keyvault.outputs.keyVaultName
    keyVaultUri: keyvault.outputs.keyVaultUri
  }
}

output webAppName string = webapp.outputs.webAppName
output webAppHostName string = webapp.outputs.webAppHostName
output keyVaultName string = keyvault.outputs.keyVaultName
