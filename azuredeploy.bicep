targetScope = 'subscription'

param location string = 'uksouth'
param resourceGroupName string = 'rg-demo-private-endpoint'
param virtualNetworkName string = 'vnet-demo-private-endpoint'
param virtualNetworkAddresses array = [
  '10.0.0.0/16'
]
param virtualNetworkDnsServers array = []
param serverSubnetName string = 'default'
param serverSubnetAddress string = '10.0.1.0/24'
param bastionSubnetAddress string = '10.0.0.192/26'
param bastionName string = 'bas-private-endpoint-demo'
param windowsServerName string = 'pedemo'
param privateDnsZoneNames array = [
  'privatelink.blob.${environment().suffixes.storage}'
  'privatelink.table.${environment().suffixes.storage}'
  'privatelink.queue.${environment().suffixes.storage}'
  'privatelink.file.${environment().suffixes.storage}'
]
param storageAccountName string = 'stdemoendpoint'
param privateLinkGroupId string = 'file'

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

module privateDnsZones 'modules/privateDnsZone/azuredeploy.bicep' = {
  name: 'privateDnsZones'
  scope: resourceGroup
  params: {
    zoneNames: privateDnsZoneNames
    virtualNetworkId: virtualNetwork.outputs.virtualNetworkId
  }
}

module storageAccount 'modules/storageAccount/azuredeploy.bicep' = {
  name: 'storageAccount'
  scope: resourceGroup
  params: {
    location: location
    storageAccountName: storageAccountName
    subnetId: virtualNetwork.outputs.serverSubnetId
    privateLinkGroupId: privateLinkGroupId
    privateDnsZoneId: privateDnsZones.outputs.privateDnsZoneIds[3]
  }
}
