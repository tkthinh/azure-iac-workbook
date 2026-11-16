targetScope = 'resourceGroup'

@description('Name of the PostgreSQL Flexible Server.')
param serverName string

@description('Microsoft Entra administrator object ID.')
param entraAdministratorObjectId string

@description('Microsoft Entra administrator principal name.')
param entraAdministratorPrincipalName string

@description('Location for the server. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Compute SKU name.')
param skuName string = 'Standard_D2s_v3'

@description('Compute tier.')
@allowed([
  'Burstable'
  'GeneralPurpose'
  'MemoryOptimized'
])
param skuTier string = 'GeneralPurpose'

@description('Allocated storage in GB.')
@minValue(32)
param storageSizeGb int = 128

@description('PostgreSQL major version.')
@allowed([
  '14'
  '15'
  '16'
])
param version string = '16'

@description('Optional tags to apply to the server.')
param tags object = {}

resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2024-08-01' = {
  name: serverName
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    version: version
    authConfig: {
      activeDirectoryAuth: 'Enabled'
      passwordAuth: 'Disabled'
      tenantId: subscription().tenantId
    }
    storage: {
      storageSizeGB: storageSizeGb
      autoGrow: 'Enabled'
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
  }
}

resource entraAdministrator 'Microsoft.DBforPostgreSQL/flexibleServers/administrators@2024-08-01' = {
  parent: postgresServer
  name: entraAdministratorObjectId
  properties: {
    principalName: entraAdministratorPrincipalName
    principalType: 'User'
    tenantId: subscription().tenantId
  }
}

output serverId string = postgresServer.id
output serverName string = postgresServer.name
output fullyQualifiedDomainName string = postgresServer.properties.fullyQualifiedDomainName
