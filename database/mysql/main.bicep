targetScope = 'resourceGroup'

@description('Name of the MySQL Flexible Server.')
param serverName string

@description('Administrator login name. The password is supplied as a secure parameter.')
param administratorLogin string

@secure()
@description('Administrator password. Do not place a real value in parameters.json.')
param administratorPassword string

@description('Location for the server. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Compute SKU name.')
param skuName string = 'Standard_D2ds_v4'

@description('Compute tier.')
@allowed([
  'Burstable'
  'GeneralPurpose'
  'BusinessCritical'
])
param skuTier string = 'GeneralPurpose'

@description('Allocated storage in GB.')
@minValue(20)
param storageSizeGb int = 32

@description('MySQL major version.')
@allowed([
  '8.0.21'
])
param version string = '8.0.21'

@description('Optional tags to apply to the server.')
param tags object = {}

resource mysqlServer 'Microsoft.DBforMySQL/flexibleServers@2023-12-30' = {
  name: serverName
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorPassword
    version: version
    storage: {
      storageSizeGB: storageSizeGb
      autoGrow: 'Enabled'
      iops: 360
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    network: {
      publicNetworkAccess: 'Enabled'
    }
  }
}

output serverId string = mysqlServer.id
output serverName string = mysqlServer.name
output fullyQualifiedDomainName string = mysqlServer.properties.fullyQualifiedDomainName
