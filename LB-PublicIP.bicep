param pIPName string = 'LB-PublicIP'
param location string = resourceGroup().location

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2025-05-01' = {
  name: pIPName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    ipAddress: '20.245.190.85'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
    ddosSettings: {
      protectionMode: 'VirtualNetworkInherited'
    }
  }
}
