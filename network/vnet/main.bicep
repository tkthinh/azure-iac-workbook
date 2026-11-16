targetScope = 'resourceGroup'

@description('Name of the virtual network.')
param virtualNetworkName string

@description('Virtual network address space CIDR blocks.')
param addressPrefixes array = [
  '10.0.0.0/16'
]

@description('Subnet definitions. Each item requires name and addressPrefix; optional serviceEndpoints may be supplied.')
param subnets array = [
  {
    name: 'default'
    addressPrefix: '10.0.0.0/24'
  }
]

@description('Location for the virtual network. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Optional tags to apply to the virtual network.')
param tags object = {}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: virtualNetworkName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: [
      for subnet in subnets: {
        name: subnet.name
        properties: {
          addressPrefix: subnet.addressPrefix
          serviceEndpoints: subnet.?serviceEndpoints ?? []
        }
      }
    ]
  }
}

output virtualNetworkId string = virtualNetwork.id
output virtualNetworkName string = virtualNetwork.name
output subnetIds array = [for subnet in subnets: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork.name, subnet.name)]
