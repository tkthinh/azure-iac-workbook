using 'main.bicep'

param clusterName = 'aks-demo-sea'
param dnsPrefix = 'aks-demo-sea'
param location = 'southeastasia'
param tags = {environment:'dev',workload:'kubernetes'}
