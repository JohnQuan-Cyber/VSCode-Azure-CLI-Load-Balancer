@description('Location for resources')
param location string = resourceGroup().location

@description('VM name')
param vmName string = 'VMJump-LB'

@description('Admin username')
param adminUsername string = 'LoadBalance'

@secure()
@description('Admin password (min 12 chars)')
param adminPassword string

@description('VNet name')
param vnetName string = 'VNet-LB-Lab'

@allowed([
  'Subnet-1'
  'Subnet-2'
  'Subnet-3'
])

@description('Subnet name')
param subnetName string = 'Subnet-1'

@description('NSG name (for NIC attachment)')
param nsgName string = 'NSG-LB-Lab'

@description('VM size')
param vmSize string = 'Standard_B1s'

resource existingVnet 'Microsoft.Network/virtualNetworks@2025-05-01' existing = {
  name: vnetName
}

resource existingSubnet 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' existing = {
  parent: existingVnet
  name: subnetName
}

resource existingNsg 'Microsoft.Network/networkSecurityGroups@2025-05-01' existing = {
  name: nsgName
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2025-05-01' = {
  name: '${vmName}-pip'
  location: location
  sku:{
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2025-05-01' = {
  name: '${vmName}-nic3'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp.id
          }
          subnet: {
            id: existingSubnet.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: existingNsg.id
    }
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2025-04-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    additionalCapabilities: {
      hibernationEnabled: false
    }
    storageProfile: {
      imageReference: {
        publisher: 'canonical'
        offer: 'ubuntu-24_04-lts'
        sku: 'server'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'

        }
        deleteOption: 'Delete'
        diskSizeGB: 30
      }
      dataDisks: []
      diskControllerType: 'SCSI'
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'ImageDefault'
          assessmentMode: 'ImageDefault'
        }
      }
      secrets: []
      allowExtensionOperations: true
    }
    securityProfile: {
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'TrustedLaunch'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties: {
            deleteOption: 'Detach'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}
