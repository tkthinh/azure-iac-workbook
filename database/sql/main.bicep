targetScope = 'resourceGroup'

@description('Name of the logical Azure SQL server.')
param serverName string

@description('Name of the Azure SQL database.')
param databaseName string

@description('Microsoft Entra administrator object ID for the SQL server.')
param entraAdministratorObjectId string

@description('Microsoft Entra administrator sign-in name.')
param entraAdministratorLogin string

@description('Location for the resources. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Azure SQL Database SKU name.')
param skuName string = 'GP_S_Gen5_2'

@description('Azure SQL Database SKU tier.')
param skuTier string = 'GeneralPurpose'

@description('Maximum database size in bytes.')
param maxSizeBytes int = 34359738368

@description('Optional tags to apply to both resources.')
param tags object = {}

resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: serverName
  location: location
  tags: tags
  properties: {
    administrators: {
      administratorType: 'ActiveDirectory'
      login: entraAdministratorLogin
      sid: entraAdministratorObjectId
      tenantId: subscription().tenantId
      azureADOnlyAuthentication: true
    }
    publicNetworkAccess: 'Enabled'
    minimalTlsVersion: '1.2'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: maxSizeBytes
    zoneRedundant: false
  }
}

output serverId string = sqlServer.id
output databaseId string = sqlDatabase.id
output fullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName
