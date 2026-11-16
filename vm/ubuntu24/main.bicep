targetScope = 'resourceGroup'

@description('Location for all resources. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Name of the Ubuntu virtual machine.')
@minLength(1)
@maxLength(64)
param vmName string

@description('Size of the virtual machine.')
param vmSize string = 'Standard_D2s_v5'

@description('Resource ID of the target subnet.')
param subnetId string

@description('Administrator username for the virtual machine.')
@minLength(1)
@maxLength(32)
param adminUsername string = 'azureuser'

@description('Authentication mode for the Ubuntu VM. SSH keys are recommended.')
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'sshPublicKey'

@description('Administrator password used only when authenticationType is password.')
@secure()
param adminPassword string = ''

@description('SSH public key used when authenticationType is sshPublicKey.')
param sshPublicKey string = ''

@description('Set to true to create and attach a public IP address.')
param enablePublicIp bool = false

@description('Size of the OS disk in GiB.')
@minValue(30)
@maxValue(2048)
param osDiskSizeGB int = 64

@description('Optional tags to apply to all resources.')
param tags object = {}

var nicName = '${vmName}-nic'
var publicIpName = '${vmName}-pip'
var linuxConfiguration = authenticationType == 'sshPublicKey'
  ? {
      disablePasswordAuthentication: true
      provisionVMAgent: true
      patchSettings: {
        patchMode: 'ImageDefault'
        assessmentMode: 'ImageDefault'
      }
      ssh: {
        publicKeys: [
          {
            path: '/home/${adminUsername}/.ssh/authorized_keys'
            keyData: sshPublicKey
          }
        ]
      }
    }
  : {
      disablePasswordAuthentication: false
      provisionVMAgent: true
      patchSettings: {
        patchMode: 'ImageDefault'
        assessmentMode: 'ImageDefault'
      }
    }

// Optional public IP for internet-reachable workloads.
resource publicIp 'Microsoft.Network/publicIPAddresses@2025-05-01' = if (enablePublicIp) {
  name: publicIpName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    deleteOption: 'Delete'
  }
}

// Network interface bound to an existing subnet so the module stays composable.
resource nic 'Microsoft.Network/networkInterfaces@2025-05-01' = {
  name: nicName
  location: location
  tags: tags
  properties: {
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          privateIPAddressVersion: 'IPv4'
          subnet: {
            id: subnetId
          }
          publicIPAddress: enablePublicIp
            ? {
                id: publicIp.id
              }
            : null
        }
      }
    ]
  }
}

// Ubuntu 24.04 Gen2 VM with Trusted Launch and managed boot diagnostics enabled by default.
resource vm 'Microsoft.Compute/virtualMachines@2025-04-01' = {
  name: vmName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'ubuntu-24_04-lts'
        sku: 'server'
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}-osdisk'
        osType: 'Linux'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        deleteOption: 'Delete'
        diskSizeGB: osDiskSizeGB
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: authenticationType == 'password' ? adminPassword : null
      linuxConfiguration: linuxConfiguration
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
    securityProfile: {
      securityType: 'TrustedLaunch'
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
  }
}

// Guest attestation complements the Trusted Launch baseline.
resource guestAttestation 'Microsoft.Compute/virtualMachines/extensions@2025-04-01' = {
  parent: vm
  name: 'GuestAttestation'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Security.LinuxAttestation'
    type: 'GuestAttestation'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
      AttestationConfig: {
        MaaSettings: {
          maaEndpoint: ''
          maaTenantName: 'GuestAttestation'
        }
      }
    }
  }
}

output vmName string = vm.name
output vmId string = vm.id
output nicId string = nic.id
output publicIpId string = enablePublicIp ? publicIp!.id : ''
output publicIpAddress string = enablePublicIp ? publicIp!.properties.ipAddress : ''
