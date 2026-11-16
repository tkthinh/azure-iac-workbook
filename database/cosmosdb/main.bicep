targetScope = 'resourceGroup'

@description('Name of the Azure Cosmos DB account. Must be globally unique.')
param accountName string

@description('Name of the SQL API database.')
param databaseName string

@description('Location for the account. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Throughput allocated to the SQL API database.')
@minValue(400)
param throughput int = 400

@description('Optional tags to apply to the account.')
param tags object = {}

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2024-11-15' = {
  name: accountName
  location: location
  tags: tags
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    minimalTlsVersion: 'Tls12'
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
  }
}

resource sqlDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-11-15' = {
  parent: cosmosAccount
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
    options: {
      throughput: throughput
    }
  }
}

output accountId string = cosmosAccount.id
output accountName string = cosmosAccount.name
output endpoint string = cosmosAccount.properties.documentEndpoint
output databaseId string = sqlDatabase.id
