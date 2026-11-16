targetScope = 'resourceGroup'

@description('Name of the Function App.')
param functionAppName string

@description('Name of the Consumption plan.')
param planName string

@description('Globally unique storage account name (3-24 lowercase letters and numbers).')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('Location for the resources. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Linux runtime stack, for example DOTNET-ISOLATED|8.0 or NODE|20.')
param linuxFxVersion string = 'DOTNET-ISOLATED|8.0'

@description('Optional app settings, provided as a key-value object.')
param appSettings object = {}

@description('Optional tags to apply to all resources.')
param tags object = {}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
  }
}

resource plan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: planName
  location: location
  tags: tags
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    reserved: true
  }
}

var storageKey = storageAccount.listKeys().keys[0].value
var storageConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageKey};EndpointSuffix=${environment().suffixes.storage}'
var customAppSettings = [
  for setting in items(appSettings): {
    name: setting.key
    value: string(setting.value)
  }
]

resource functionApp 'Microsoft.Web/sites@2024-04-01' = {
  name: functionAppName
  location: location
  tags: tags
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: plan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      appSettings: concat([
        {
          name: 'AzureWebJobsStorage'
          value: storageConnectionString
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
      ], customAppSettings)
    }
  }
}

output functionAppId string = functionApp.id
output functionAppName string = functionApp.name
output defaultHostname string = functionApp.properties.defaultHostName
output principalId string = functionApp.identity.principalId
