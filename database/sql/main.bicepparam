using 'main.bicep'

param serverName = 'sql-demo-sea-001'
param databaseName = 'appdb'
param entraAdministratorObjectId = '<entra-administrator-object-id>'
param entraAdministratorLogin = '<entra-administrator-sign-in-name>'
param location = 'southeastasia'
param tags = {environment:'dev',workload:'database'}
