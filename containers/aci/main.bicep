targetScope = 'resourceGroup'

@description('Name of the container group.')
param containerGroupName string

@description('Container image, including registry hostname when applicable.')
param containerImage string

@description('Location for the container group. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('CPU cores allocated to the container.')
param cpu int = 1

@description('Memory in GB allocated to the container.')
param memoryInGb int = 2

@description('Port exposed by the container.')
param port int = 80

@description('Expose the container group on a public IP address.')
param publicIpEnabled bool = false

@description('Container restart policy.')
@allowed([
  'Always'
  'OnFailure'
  'Never'
])
param restartPolicy string = 'Always'

@description('Optional non-secret environment variables. Use objects with name and value properties.')
param environmentVariables array = []

@description('Optional tags to apply to the container group.')
param tags object = {}

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: containerGroupName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    osType: 'Linux'
    restartPolicy: restartPolicy
    containers: [
      {
        name: 'app'
        properties: {
          image: containerImage
          resources: {
            requests: {
              cpu: cpu
              memoryInGB: memoryInGb
            }
          }
          ports: [
            {
              port: port
            }
          ]
          environmentVariables: environmentVariables
        }
      }
    ]
    ipAddress: publicIpEnabled ? {
      type: 'Public'
      ports: [
        {
          protocol: 'TCP'
          port: port
        }
      ]
    } : null
  }
}

output containerGroupId string = containerGroup.id
output containerGroupName string = containerGroup.name
output ipAddress string = publicIpEnabled ? containerGroup.properties.ipAddress.ip : ''
