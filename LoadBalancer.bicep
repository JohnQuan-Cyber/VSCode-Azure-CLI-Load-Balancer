@description('Location for resources')
param location string = resourceGroup().location

@description('name of Load Balancer')
param lbName string = 'LoadB-LAb'

@description('VNet name')
param vnetName string = 'VNet-LB-Lab'

resource existingVnet 'Microsoft.Network/virtualNetworks@2025-05-01' existing = {
  name: vnetName
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: 'LB-PublicIP'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource LoadBalancer 'Microsoft.Network/loadBalancers@2024-07-01' = {
  name: lbName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'LB-Front'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'LB-Back'
      }
    ]
    loadBalancingRules: [
      {
        name: 'HTTP-RR'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, 'LB-Front')
          }
          frontendPort: 80
          backendPort: 80
          protocol: 'Tcp'
          idleTimeoutInMinutes: 4
          enableFloatingIP: false
          loadDistribution: 'Default'
          disableOutboundSnat: true
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, 'LB-Back')
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', lbName, 'HTTP-Health')
          }
        }
      }
    ]
    probes: [
      {
        name: 'HTTP-Health'
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 5
          numberOfProbes: 1
          probeThreshold: 1
          noHealthyBackendsBehavior: 'AllProbedDown'
        }
      }
    ]
  }
}

resource loadBalancerBack 'Microsoft.Network/loadBalancers/backendAddressPools@2024-07-01' = {
  parent: LoadBalancer
  name: 'LB-Back'
  properties: {
    loadBalancerBackendAddresses: [
      {
        name: 'VM1-LB'
        properties: {
          ipAddress: '10.0.0.10'
          virtualNetwork: {
            id: existingVnet.id
          }
        }
      }
      {
        name: 'VM2-LB'
        properties: {
          ipAddress: '10.0.0.11'
          virtualNetwork: {
            id: existingVnet.id
          }
        }
      }
    ]
  }
}
