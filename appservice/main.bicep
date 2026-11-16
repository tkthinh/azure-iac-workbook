targetScope = 'resourceGroup'

@description('Name of the App Service plan.')
param planName string

@description('Name of the web app.')
param webAppName string

@description('Location for the resources. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('App Service plan tier. Select Free (F1), Basic (B1-B3), or Premium (P0v3-P3v3).')
@allowed([
  'Free'
  'Basic'
  'Premium'
])
param planTier string = 'Premium'

@description('App Service plan SKU name. Use a SKU compatible with planTier, for example F1, B1, or P0v3.')
param skuName string = 'P0v3'

@description('Operating system for the App Service plan and web app.')
@allowed([
  'Linux'
  'Windows'
])
param osType string = 'Linux'

@description('Runtime stack for Linux web apps. Examples: DOTNETCORE|8.0, PHP|8.2, NODE|20-lts, TOMCAT|9.0-jre8, or PYTHON|3.11.')
param linuxFxVersion string = 'DOTNETCORE|8.0'

@description('Runtime settings for Windows web apps. Use the setting for the selected language, for example {netFrameworkVersion: \'v8.0\'}, {phpVersion: \'8.2\'}, {nodeVersion: \'~20\'}, or {javaVersion: \'17\', javaContainer: \'TOMCAT\', javaContainerVersion: \'9.0\'}. Python is supported on Linux only.')
param windowsRuntime object = {
  netFrameworkVersion: 'v8.0'
}

@description('Optional app settings, provided as a key-value object.')
param appSettings object = {}

@description('Enable regional outbound VNet integration.')
param enableVnetIntegration bool = true

@description('VNet containing the integration subnet.')
param virtualNetworkName string = ''

@description('Subnet used for regional VNet integration.')
param integrationSubnetName string = 'app-integration'

@description('Optional tags to apply to both resources.')
param tags object = {}

var skuTier = planTier == 'Premium' ? 'PremiumV3' : planTier

var appSettingsList = [
  for setting in items(appSettings): {
    name: setting.key
    value: string(setting.value)
  }
]

var commonSiteConfig = {
  minTlsVersion: '1.2'
  ftpsState: 'Disabled'
  appSettings: appSettingsList
}

resource plan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: planName
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    reserved: osType == 'Linux'
  }
}

resource webApp 'Microsoft.Web/sites@2024-04-01' = {
  name: webAppName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: plan.id
    httpsOnly: true
    siteConfig: osType == 'Linux' ? union(commonSiteConfig, {
      linuxFxVersion: linuxFxVersion
    }) : union(commonSiteConfig, windowsRuntime)
  }
}

resource vnetIntegration 'Microsoft.Web/sites/virtualNetworkConnections@2024-04-01' = if (enableVnetIntegration) {
  parent: webApp
  name: 'virtualNetwork'
  properties: {
    vnetResourceId: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, integrationSubnetName)
    isSwift: true
  }
}

output webAppId string = webApp.id
output webAppName string = webApp.name
output defaultHostname string = webApp.properties.defaultHostName
output principalId string = webApp.identity.principalId
