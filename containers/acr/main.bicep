targetScope = 'resourceGroup'

@description('Name of the Azure Container Registry. Use 5-50 alphanumeric characters.')
@minLength(5)
@maxLength(50)
param registryName string

@description('Location for the registry. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Pricing tier for the registry.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param tier string = 'Standard'

@description('Optional tags to apply to the registry.')
param tags object = {}

// Deploy a secure-by-default Azure Container Registry with Microsoft Entra authentication.
resource registry 'Microsoft.ContainerRegistry/registries@2025-04-01' = {
  name: registryName
  location: location
  tags: tags
  sku: {
    name: tier
  }
  properties: {
    adminUserEnabled: false
    anonymousPullEnabled: false
    dataEndpointEnabled: false
    publicNetworkAccess: 'Enabled'
    networkRuleBypassOptions: 'AzureServices'
    policies: {
      azureADAuthenticationAsArmPolicy: {
        status: 'enabled'
      }
      exportPolicy: {
        status: 'enabled'
      }
      quarantinePolicy: {
        status: 'disabled'
      }
      retentionPolicy: {
        status: 'disabled'
      }
      trustPolicy: {
        status: 'disabled'
        type: 'Notary'
      }
    }
    zoneRedundancy: 'Disabled'
  }
}

output registryName string = registry.name
output registryId string = registry.id
output loginServer string = registry.properties.loginServer
output sku string = registry.sku.name
