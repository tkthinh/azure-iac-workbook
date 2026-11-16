using 'main.bicep'

param environmentName = 'cae-demo-sea'
param containerAppName = 'ca-demo-sea'
param containerImage = 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
param location = 'southeastasia'
param externalIngress = true
param tags = {environment:'dev',workload:'container-app'}
