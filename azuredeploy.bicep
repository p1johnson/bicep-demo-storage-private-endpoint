targetScope = 'subscription'

param location string = 'uksouth'
param resourceGroupName string = 'rg-bicep-demo'
param virtualNetworkName string = 'vnet-bicep-demo'
param virtualNetworkAddresses array = [
  '10.0.0.0/16'
]
param virtualNetworkDnsServers array = []
param serverSubnetName string = 'default'
param serverSubnetAddress string = '10.0.1.0/24'
param bastionSubnetAddress string = '10.0.0.192/26'
param bastionName string = 'bas-bicep-demo'
param windowsServerName string = 'bicepdemo'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module virtualNetwork 'modules/virtualNetwork/azuredeploy.bicep' = {
  name: 'virtualNetwork'
  scope: resourceGroup
  params: {
    location: location
    virtualNetworkName: virtualNetworkName
    virtualNetworkAddresses: virtualNetworkAddresses
    virtualNetworkDnsServers: virtualNetworkDnsServers
    serverSubnetName: serverSubnetName
    serverSubnetAddress: serverSubnetAddress
    bastionSubnetAddress: bastionSubnetAddress
  }
}

module azureBastion 'modules/azureBastion/azuredeploy.bicep' = {
  name: 'azureBastion'
  scope: resourceGroup
  params: {
    location: location
    bastionName: bastionName
    bastionSubnetId: virtualNetwork.outputs.bastionSubnetId
  }
}

module windowsServer 'modules/windowsServer/azuredeploy.bicep' = {
  name: 'windowsServer'
  scope: resourceGroup
  params: {
    location: location
    serverName: windowsServerName
    subnetId: virtualNetwork.outputs.serverSubnetId
  }
}
