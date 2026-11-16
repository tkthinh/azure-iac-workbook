using 'main.bicep'

param virtualNetworkName = 'vnet-demo-sea'
param addressPrefixes = ['10.0.0.0/16']
param subnets = [{name:'app',addressPrefix:'10.0.1.0/24'}]
param location = 'southeastasia'
param tags = {environment:'dev',workload:'network'}
