using 'main.bicep'

param registryName = 'acrdemo001'
param location = 'southeastasia'
param tier = 'Standard'
param tags = {environment:'dev',workload:'container-registry'}
