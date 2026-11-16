targetScope = 'resourceGroup'
param publicIpName string
param location string = resourceGroup().location
param tags object = {}
resource publicIp 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: publicIpName
  location: location
  tags: tags
  sku: { name: 'Standard' }
  properties: { publicIPAllocationMethod: 'Static' }
}
output id string = publicIp.id
output ipAddress string = publicIp.properties.ipAddress
