param location string = resourceGroup().location

// We are creating a minimum and maximum length for the password 
@minLength(3)
@maxLength(24)
param nsgName string = 'LB-Lab'

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2025-05-01' = {
  name: 'NSG-${nsgName}'
  location: location
  properties: {
    securityRules: [
      {
        // First rule in the NSG is an inbound rule allowing HTTP 
        name: 'Allow_HTTP'
        properties: {
          description: 'Allowing HTTP'
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        // Second rule in the NSG is an inbound rule allowing RDP
        name: 'Allow_SSH'
        properties: {
          description:'Allowing SSH'
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
    ]
  }
}

