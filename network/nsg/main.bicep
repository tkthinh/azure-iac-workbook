targetScope = 'resourceGroup'

@description('Name of the network security group.')
param networkSecurityGroupName string

@description('Location for the network security group. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Inbound or outbound security rules. Each item follows the Microsoft.Network security rule shape.')
param securityRules array = []

@description('Optional tags to apply to the network security group.')
param tags object = {}

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: networkSecurityGroupName
  location: location
  tags: tags
  properties: {
    securityRules: securityRules
  }
}

output networkSecurityGroupId string = nsg.id
output networkSecurityGroupName string = nsg.name
