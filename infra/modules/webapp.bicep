param location string
param projectName string
param tags object

param appInsightsConnectionString string
param snetWebIntegrationId string

param keyVaultName string
param keyVaultUri string

var planName = 'asp-${projectName}'
var webAppName = 'app-${projectName}-${uniqueString(resourceGroup().id)}'

resource plan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: planName
  location: location
  tags: tags
  sku: {
    name: 'P1v3'
    tier: 'PremiumV3'
    capacity: 1
  }
  properties: {
    reserved: false
  }
}

resource web 'Microsoft.Web/sites@2023-12-01' = {
  name: webAppName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: plan.id
    siteConfig: {
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      http20Enabled: true
      alwaysOn: true
      vnetRouteAllEnabled: true

      appSettings: [
        { name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'; value: appInsightsConnectionString }
        { name: 'KeyVaultUri'; value: keyVaultUri }

        // Example secret reference – you will create secret "DbPassword" after deploy
        { name: 'DbPassword'; value: '@Microsoft.KeyVault(SecretUri=https://${keyVaultName}.vault.azure.net/secrets/DbPassword/)' }
      ]
    }
  }
}

// Swift VNet Integration
resource vnetIntegration 'Microsoft.Web/sites/virtualNetworkConnections@2023-12-01' = {
  name: '${web.name}/vnet'
  properties: {
    vnetResourceId: snetWebIntegrationId
    isSwift: true
  }
}

// RBAC: allow web app identity to read Key Vault secrets
resource kvSecretsUserRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, web.identity.principalId, 'kv-secrets-user')
  scope: resourceId('Microsoft.KeyVault/vaults', keyVaultName)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6') // Key Vault Secrets User
    principalId: web.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

output webAppName string = web.name
output webAppHostName string = web.properties.defaultHostName
output webAppPrincipalId string = web.identity.principalId
