using 'main.bicep'

param location = 'southeastasia'
param vmName = 'vm-windows-demo'
param vmSize = 'Standard_B2s'
param subnetId = '/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Network/virtualNetworks/<vnet-name>/subnets/<subnet-name>'
param adminUsername = 'azureuser'
param adminPassword = '<supply-securely-at-deployment>'
param enablePublicIp = false
param osDiskSizeGB = 127
param tags = {environment:'dev',workload:'windows-vm'}
