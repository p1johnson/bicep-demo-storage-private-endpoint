targetScope = 'resourceGroup'

param zoneNames array
param virtualNetworkId string

output privateDnsZoneIds array = [for (zoneName, i) in zoneNames: privateDnsZone[i].id]

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = [for zoneName in zoneNames: {
  name: zoneName
  location: 'global'
}]

resource virtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (zoneName, i) in zoneNames: {
  name: last(split(virtualNetworkId, '/'))
  location: 'global'
  parent: privateDnsZone[i]
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}]
