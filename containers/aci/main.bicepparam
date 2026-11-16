using 'main.bicep'

param containerGroupName = 'aci-demo-sea'
param containerImage = 'mcr.microsoft.com/azuredocs/aci-helloworld:latest'
param location = 'southeastasia'
param publicIpEnabled = true
param tags = {environment:'dev',workload:'container-instance'}
