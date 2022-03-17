targetScope = 'resourceGroup'

param location string
param storageAccountName string
param storageAccountKind string = 'StorageV2'
param storageAccountSku string = 'Standard_LRS'
param privateEndpointName string = 'pe-${storageAccountName}'
param subnetId string
param privateLinkGroupId string
param privateDnsZoneId string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSku
  }
  kind: storageAccountKind
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            privateLinkGroupId
          ]
        }
      }
    ]
  }
}

resource privateEndpointDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: 'privateDns'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateLinkGroupId
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}
