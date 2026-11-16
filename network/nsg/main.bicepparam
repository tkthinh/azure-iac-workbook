using 'main.bicep'

param networkSecurityGroupName = 'nsg-demo-sea'
param location = 'southeastasia'
param securityRules = []
param tags = {environment:'dev',workload:'network'}
