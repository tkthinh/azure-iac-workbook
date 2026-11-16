using 'main.bicep'

param serverName = 'psql-demo-sea-001'
param entraAdministratorObjectId = '<entra-administrator-object-id>'
param entraAdministratorPrincipalName = '<entra-administrator-sign-in-name>'
param location = 'southeastasia'
param tags = {environment:'dev',workload:'database'}
