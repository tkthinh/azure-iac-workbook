targetScope = 'resourceGroup'

@description('Name of the Container Apps managed environment.')
param environmentName string

@description('Name of the container app.')
param containerAppName string

@description('Container image, including registry hostname when applicable.')
param containerImage string

@description('Location for the resources. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Container CPU cores.')
param cpu int = 1

@description('Container memory, for example 1Gi.')
param memory string = '1Gi'

@description('Port exposed by the application container.')
param targetPort int = 8080

@description('Expose the app publicly. Defaults to private ingress.')
param externalIngress bool = false

@description('Optional environment variables for the primary container. Use objects with name and value properties.')
param environmentVariables array = []

@description('Optional tags applied to both resources.')
param tags object = {}

resource environment 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: environmentName
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'none'
    }
  }
}

resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: containerAppName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: environment.id
    configuration: {
      ingress: {
        external: externalIngress
        targetPort: targetPort
        transport: 'auto'
      }
    }
    template: {
      containers: [
        {
          name: 'app'
          image: containerImage
          resources: {
            cpu: cpu
            memory: memory
          }
          env: environmentVariables
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 3
      }
    }
  }
}

output environmentId string = environment.id
output containerAppId string = containerApp.id
output containerAppName string = containerApp.name
output defaultHostname string = containerApp.properties.configuration.ingress.fqdn
