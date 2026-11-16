targetScope = 'resourceGroup'
param natGatewayName string
param publicIpResourceId string
param location string = resourceGroup().location
param tags object = {}
resource natGateway 'Microsoft.Network/natGateways@2024-05-01' = {
  name: natGatewayName
  location: location
  tags: tags
  sku: { name: 'Standard' }
  properties: {
    publicIpAddresses: [
      {
        id: publicIpResourceId
      }
    ]
  }
}
output id string = natGateway.id
