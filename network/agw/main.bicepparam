using 'main.bicep'

param applicationGatewayName = 'agw-demo-sea'
param subnetId = '/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Network/virtualNetworks/<vnet-name>/subnets/ApplicationGatewaySubnet'
param location = 'southeastasia'
param tags = {environment:'dev',workload:'network'}
