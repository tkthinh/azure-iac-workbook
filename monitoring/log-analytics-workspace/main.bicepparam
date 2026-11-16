using 'main.bicep'

param workspaceName = 'law-prod-sea-01'
param location = 'southeastasia'
param skuName = 'PerGB2018'
param retentionInDays = 30
param dailyQuotaGb = -1
param disableLocalAuth = true
param tags = {environment:'prod',workload:'shared-monitoring'}
