targetScope = 'resourceGroup'
param topicName string
param location string = resourceGroup().location
param tags object = {}
resource topic 'Microsoft.EventGrid/topics@2023-12-15-preview' = {
  name: topicName
  location: location
  tags: tags
  properties: { publicNetworkAccess: 'Enabled' }
}
output id string = topic.id
output endpoint string = topic.properties.endpoint
