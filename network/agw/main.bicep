targetScope = 'resourceGroup'

@description('Name of the Application Gateway.')
param applicationGatewayName string

@description('Resource ID of a dedicated Application Gateway subnet.')
param subnetId string

@description('Location for the Application Gateway. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Application Gateway capacity.')
@minValue(1)
param capacity int = 2

@description('Optional tags to apply to the Application Gateway and public IP.')
param tags object = {}

resource publicIp 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: '${applicationGatewayName}-pip'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource applicationGateway 'Microsoft.Network/applicationGateways@2024-05-01' = {
  name: applicationGatewayName
  location: location
  tags: tags
  sku: {
    name: 'WAF_v2'
    tier: 'WAF_v2'
  }
  properties: {
    autoscaleConfiguration: {
      minCapacity: capacity
      maxCapacity: capacity + 2
    }
    gatewayIPConfigurations: [
      {
        name: 'gateway-ip-config'
        properties: {
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'public-frontend'
        properties: {
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'http'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'default-backend'
        properties: {
          backendAddresses: []
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'default-http-settings'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
        }
      }
    ]
    httpListeners: [
      {
        name: 'http-listener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'public-frontend')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'http')
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'default-rule'
        properties: {
          ruleType: 'Basic'
          priority: 100
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'http-listener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'default-backend')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'default-http-settings')
          }
        }
      }
    ]
    enableHttp2: true
    firewallPolicy: null
  }
}

output applicationGatewayId string = applicationGateway.id
output applicationGatewayName string = applicationGateway.name
output publicIpAddress string = publicIp.properties.ipAddress
