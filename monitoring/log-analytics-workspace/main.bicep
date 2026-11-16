targetScope = 'resourceGroup'

@description('Name of the Log Analytics workspace.')
@minLength(4)
@maxLength(63)
param workspaceName string

@description('Azure region for the workspace. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Workspace SKU.')
@allowed([
  'PerGB2018'
  'CapacityReservation'
])
param skuName string = 'PerGB2018'

@description('Data retention in days. OperationalInsights supports 30 to 730 days.')
@minValue(30)
@maxValue(730)
param retentionInDays int = 30

@description('Daily ingestion quota in GB. Use -1 to keep the quota unlimited.')
@minValue(-1)
param dailyQuotaGb int = -1

@description('Reservation capacity in GB per day. Required only when skuName is CapacityReservation.')
@minValue(100)
param reservationCapacityInGbPerDay int = 100

@description('Enable internet ingestion for agents and diagnostic settings.')
param publicNetworkAccessForIngestion string = 'Enabled'

@description('Enable internet query access to the workspace.')
param publicNetworkAccessForQuery string = 'Enabled'

@description('Disable shared-key local authentication to prefer Azure AD based access.')
param disableLocalAuth bool = true

@description('Optional tags to apply to the workspace.')
param tags object = {}

// Build the SKU object dynamically so reservation capacity is only included when required.
var workspaceSku = skuName == 'CapacityReservation'
  ? {
      name: skuName
      capacityReservationLevel: reservationCapacityInGbPerDay
    }
  : {
      name: skuName
    }

// Deploy a Log Analytics workspace with production-oriented defaults and optional quota controls.
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {
    sku: workspaceSku
    retentionInDays: retentionInDays
    workspaceCapping: {
      dailyQuotaGb: dailyQuotaGb
    }
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    features: {
      disableLocalAuth: disableLocalAuth
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

// Return the values most commonly needed by downstream modules and operational tooling.
output workspaceName string = logAnalyticsWorkspace.name
output workspaceResourceId string = logAnalyticsWorkspace.id
output workspaceCustomerId string = logAnalyticsWorkspace.properties.customerId
