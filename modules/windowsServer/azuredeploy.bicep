targetScope = 'resourceGroup'

param location string = resourceGroup().location
param serverName string
param size string = 'Standard_D2s_v3'
param adminUsername string = 'azureuser'
@secure()
param adminPassword string = newGuid()
param timeZone string = 'UTC'
param imagePublisher string = 'MicrosoftWindowsServer'
param imageOffer string = 'WindowsServer'
param imageSku string = '2019-Datacenter'
param imageVersion string = 'latest'
param osDiskName string = 'mdk-${serverName}-os'
param osDiskType string = 'StandardSSD_LRS'
param networkInterfaceName string = 'nic-${serverName}'
param subnetId string
param dscUrl string = 'https://gist.github.com/p1johnson/3817a791bd82d1d0e469104432128f59/raw/JumpServer.zip'
param dscScript string = 'JumpServer.ps1'
param dscFunction string = 'JumpServer'

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: serverName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: size
    }
    osProfile: {
      computerName: serverName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        timeZone: timeZone
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSku
        version: imageVersion
      }
      osDisk: {
        createOption: 'FromImage'
        deleteOption: 'Delete'
        name: osDiskName
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
    }
  }
}

resource virtualMachineDscExtension 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name: 'powershellDsc'
  location: location
  parent: virtualMachine
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.9'
    autoUpgradeMinorVersion: true
    settings: {
      wmfVersion: 'latest'
      configuration: {
        url: dscUrl
        script: dscScript
        function: dscFunction
      }
    }
  }
}
