targetScope = 'resourceGroup'

@description('Globally unique storage account name (3-24 lowercase letters and numbers).')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('Azure region for the storage account. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Storage account SKU.')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
])
param skuName string = 'Standard_LRS'

@description('Storage account kind.')
@allowed([
  'StorageV2'
  'BlockBlobStorage'
  'FileStorage'
])
param kind string = 'StorageV2'

@description('Default access tier for blob data.')
@allowed([
  'Hot'
  'Cool'
])
param accessTier string = 'Hot'

@description('Minimum TLS version for data plane requests.')
@allowed([
  'TLS1_2'
])
param minimumTlsVersion string = 'TLS1_2'

@description('Controls public internet access to the storage account endpoint.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Allow anonymous public access to blobs and containers.')
param allowBlobPublicAccess bool = false

@description('Allow shared key authorization. Set false to prefer Azure AD authentication.')
param allowSharedKeyAccess bool = true

@description('Optional tags to apply to the storage account.')
param tags object = {}

// Deploy a secure-by-default storage account with reusable configuration knobs.
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  tags: tags
  kind: kind
  sku: {
    name: skuName
  }
  properties: {
    accessTier: accessTier
    minimumTlsVersion: minimumTlsVersion
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    publicNetworkAccess: publicNetworkAccess
    supportsHttpsTrafficOnly: true
    allowCrossTenantReplication: false
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    isVersioningEnabled: true
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource privateContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'default'
  properties: {
    publicAccess: 'None'
  }
}

// Return identifiers commonly consumed by downstream modules.
output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
output primaryEndpoints object = storageAccount.properties.primaryEndpoints
