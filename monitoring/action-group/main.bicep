targetScope = 'resourceGroup'

param actionGroupName string
param shortName string
@description('Email receivers. Each item requires name and emailAddress.')
param emailReceivers array = []
param location string = 'global'
param tags object = {}

resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: actionGroupName
  location: location
  tags: tags
  properties: {
    groupShortName: shortName
    enabled: true
    emailReceivers: emailReceivers
  }
}

output id string = actionGroup.id
output name string = actionGroup.name
