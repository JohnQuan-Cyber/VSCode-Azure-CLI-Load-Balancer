
param location string = resourceGroup().location
param vnetName string = 'LB-Lab'

resource vnet 'Microsoft.Network/virtualNetworks@2025-05-01' = {
  name: 'VNet-${vnetName}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
  }
  
  @batchSize(1)
  resource subnets 'subnets' = [for i in range(0, 3): {
    name: 'Subnet-${i + 1}'
    properties: {
      addressPrefix: '10.0.${i}.0/24'
    }
  }]
}
