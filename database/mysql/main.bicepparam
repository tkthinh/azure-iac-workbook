using 'main.bicep'

param serverName = 'mysql-demo-sea-001'
param administratorLogin = 'dbadmin'
param administratorPassword = '<supply-securely-at-deployment>'
param location = 'southeastasia'
param tags = {environment:'dev',workload:'database'}
