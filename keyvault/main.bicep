targetScope = 'resourceGroup'

@description('Name of the Key Vault. Use 3-24 alphanumeric characters and hyphens.')
@minLength(3)
@maxLength(24)
param vaultName string

@description('Location for the vault. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Enable public network access. Set to Disabled when private endpoints are deployed separately.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Optional tags to apply to the vault.')
param tags object = {}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: vaultName
  location: location
  tags: tags
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true
    enablePurgeProtection: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    publicNetworkAccess: publicNetworkAccess
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: publicNetworkAccess == 'Enabled' ? 'Allow' : 'Deny'
    }
  }
}

output vaultId string = keyVault.id
output vaultName string = keyVault.name
output vaultUri string = keyVault.properties.vaultUri
