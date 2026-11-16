targetScope = 'resourceGroup'

@description('Name of the Automation Account.')
@minLength(6)
@maxLength(50)
param automationAccountName string

@description('Location for the Automation Account. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('SKU for the Automation Account.')
@allowed([
  'Basic'
  'Free'
])
param skuName string = 'Basic'

@description('Optional tags to apply to the Automation Account.')
param tags object = {}

// Deploy a reusable Automation Account with Microsoft-managed encryption and Entra-only authentication.
resource automationAccount 'Microsoft.Automation/automationAccounts@2024-10-23' = {
  name: automationAccountName
  location: location
  tags: tags
  properties: {
    disableLocalAuth: true
    encryption: {
      keySource: 'Microsoft.Automation'
    }
    publicNetworkAccess: false
    sku: {
      name: skuName
    }
  }
}

output automationAccountName string = automationAccount.name
output automationAccountId string = automationAccount.id
output automationAccountLocation string = automationAccount.location
output skuName string = automationAccount.properties.sku.name
