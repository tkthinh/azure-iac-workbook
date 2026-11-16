targetScope = 'resourceGroup'
param storageAccountName string
param shareName string
@minValue(1)
param quotaGiB int = 100
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = { name: storageAccountName }
resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2023-05-01' existing = {
  parent: storageAccount
  name: 'default'
}
resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-05-01' = {
  parent: fileService
  name: shareName
  properties: {
    shareQuota: quotaGiB
    enabledProtocols: 'SMB'
  }
}
output id string = fileShare.id
