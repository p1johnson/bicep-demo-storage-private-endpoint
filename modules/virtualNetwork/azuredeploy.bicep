targetScope = 'resourceGroup'

param location string
param virtualNetworkName string
param virtualNetworkAddresses array
param virtualNetworkDnsServers array = []
param serverSubnetName string
param serverSubnetAddress string
param bastionSubnetAddress string

output serverSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, serverSubnetName)
output bastionSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, 'AzureBastionSubnet')

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: virtualNetworkAddresses
    }
    dhcpOptions: {
      dnsServers: virtualNetworkDnsServers
    }
    subnets: [
      {
        name: serverSubnetName
        properties: {
          addressPrefix: serverSubnetAddress
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: bastionSubnetAddress
        }
      }
    ]
  }
}
