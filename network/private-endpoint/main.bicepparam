using 'main.bicep'

param privateEndpointName = 'pe-demo-sea'
param subnetResourceId = '<subnet-resource-id>'
param privateLinkResourceId = '<private-link-resource-id>'
param groupIds = ['blob']
param location = 'southeastasia'
