targetScope = 'resourceGroup'

@description('Name of the Azure Cache for Redis instance. Must be globally unique.')
param cacheName string

@description('Location for the cache. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Cache SKU name.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param skuName string = 'Standard'

@description('Cache capacity. Valid values depend on the selected SKU.')
@minValue(0)
param capacity int = 1

@description('Optional tags to apply to the cache.')
param tags object = {}

resource redisCache 'Microsoft.Cache/redis@2024-11-01' = {
  name: cacheName
  location: location
  tags: tags
  properties: {
    enableNonSslPort: false
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
  sku: {
    name: skuName
    family: skuName == 'Premium' ? 'P' : 'C'
    capacity: capacity
  }
}

output cacheId string = redisCache.id
output cacheName string = redisCache.name
output hostName string = redisCache.properties.hostName
output sslPort int = redisCache.properties.sslPort
