using 'main.bicep'

param functionAppName = 'func-demo-sea-001'
param planName = 'asp-func-demo-sea'
param storageAccountName = 'stfuncdemosea001'
param location = 'southeastasia'
param tags = {environment:'dev',workload:'function-app'}
