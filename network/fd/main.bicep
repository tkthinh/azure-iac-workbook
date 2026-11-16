targetScope = 'resourceGroup'

@description('Name of the Azure Front Door profile.')
param profileName string

@description('Location for the profile. Azure Front Door uses global deployment.')
param location string = 'global'

@description('Optional tags to apply to the profile.')
param tags object = {}

resource frontDoorProfile 'Microsoft.Cdn/profiles@2024-02-01' = {
  name: profileName
  location: location
  tags: tags
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
}

output profileId string = frontDoorProfile.id
output profileName string = frontDoorProfile.name
