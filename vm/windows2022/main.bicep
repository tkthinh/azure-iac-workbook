targetScope = 'resourceGroup'

@description('Location for all resources. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Name of the Windows virtual machine. Keep this within 15 characters to satisfy the Windows computer name limit.')
@minLength(1)
@maxLength(15)
param vmName string

@description('Size of the virtual machine.')
param vmSize string = 'Standard_D2s_v5'

@description('Resource ID of the target subnet.')
param subnetId string

@description('Administrator username for the virtual machine.')
@minLength(1)
@maxLength(20)
param adminUsername string = 'azureadmin'

@description('Administrator password for the virtual machine.')
@secure()
@minLength(12)
param adminPassword string

@description('Set to true to create and attach a public IP address.')
param enablePublicIp bool = false

@description('Size of the OS disk in GiB.')
@minValue(127)
@maxValue(2048)
param osDiskSizeGB int = 127

@description('Optional tags to apply to all resources.')
param tags object = {}

var nicName = '${vmName}-nic'
var publicIpName = '${vmName}-pip'

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

// Network interface bound to an existing subnet so the module composes with shared networking stacks.
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

// Windows Server 2022 Gen2 VM with Trusted Launch and managed boot diagnostics enabled by default.
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
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-g2'
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}-osdisk'
        osType: 'Windows'
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
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByPlatform'
          assessmentMode: 'AutomaticByPlatform'
        }
      }
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
    publisher: 'Microsoft.Azure.Security.WindowsAttestation'
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
