using 'main.bicep'

param planName = 'asp-demo-sea'
param webAppName = 'app-demo-sea-001'
param location = 'southeastasia'
param planTier = 'Premium'
param skuName = 'P0v3'
param osType = 'Linux'
param linuxFxVersion = 'DOTNETCORE|8.0'
param windowsRuntime = { netFrameworkVersion: 'v8.0' }
param enableVnetIntegration = true
param virtualNetworkName = 'vnet-demo-sea'
param integrationSubnetName = 'app-integration'
param tags = { environment: 'dev', workload: 'web-app' }
