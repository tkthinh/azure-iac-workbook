using 'main.bicep'

param location = 'southeastasia'
param vmName = 'vm-ubuntu-demo'
param vmSize = 'Standard_B1ms'
param subnetId = '/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Network/virtualNetworks/<vnet-name>/subnets/<subnet-name>'
param adminUsername = 'azureuser'
param authenticationType = 'sshPublicKey'
param adminPassword = ''
param sshPublicKey = '<your-ssh-public-key>'
param enablePublicIp = false
param osDiskSizeGB = 64
param tags = {autoStart:'true',environment:'dev',workload:'linux-vm'}
