using 'main.bicep'

param storageAccountName = 'stprodsea01'
param location = 'southeastasia'
param skuName = 'Standard_LRS'
param kind = 'StorageV2'
param accessTier = 'Hot'
param minimumTlsVersion = 'TLS1_2'
param publicNetworkAccess = 'Enabled'
param allowBlobPublicAccess = false
param allowSharedKeyAccess = true
param tags = {environment:'prod',workload:'shared-storage'}
