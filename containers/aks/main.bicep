targetScope = 'resourceGroup'

@description('Name of the Azure Kubernetes Service cluster.')
param clusterName string

@description('DNS prefix used by the managed public endpoint.')
param dnsPrefix string

@description('Location for the cluster. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Virtual machine size for the system node pool.')
param nodeVmSize string = 'Standard_D2s_v5'

@description('Initial system node count.')
@minValue(1)
param nodeCount int = 3

@description('Enable cluster autoscaler for the system node pool.')
param enableAutoScaling bool = true

@description('Minimum system node count when autoscaling is enabled.')
@minValue(1)
param minNodeCount int = 1

@description('Maximum system node count when autoscaling is enabled.')
@minValue(1)
param maxNodeCount int = 5

@description('Optional tags to apply to the cluster.')
param tags object = {}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-10-01' = {
  name: clusterName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: dnsPrefix
    enableRBAC: true
    disableLocalAccounts: true
    agentPoolProfiles: [
      {
        name: 'system'
        mode: 'System'
        count: enableAutoScaling ? null : nodeCount
        vmSize: nodeVmSize
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        enableAutoScaling: enableAutoScaling
        minCount: enableAutoScaling ? minNodeCount : null
        maxCount: enableAutoScaling ? maxNodeCount : null
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'azure'
      loadBalancerSku: 'standard'
    }
  }
}

output clusterId string = aksCluster.id
output clusterName string = aksCluster.name
output kubeletIdentity object = aksCluster.properties.identityProfile.kubeletidentity
