targetScope = 'resourceGroup'

param location string
param bastionName string
param bastionPublicIpName string = 'pip-${bastionName}'
param bastionSubnetId string

resource bastionPublicIp 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: bastionPublicIpName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2021-05-01' = {
  name: bastionName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          subnet: {
            id: bastionSubnetId
          }
          publicIPAddress: {
            id: bastionPublicIp.id
          }
        }
      }
    ]
  }
}
