param location string = resourceGroup().location
param networkInterfaceName string = 'vmfleetcommander279'
param networkSecurityGroupName string = 'vmfleetcommander-nsg'
param networkSecurityGroupRules array = []
param subnetName string = 'default'
param virtualNetworkName string = 'vmfleetcommander-vnet'
param addressPrefixes array = [
  '10.0.0.0/16'
]
param subnets array = [{
  name:'default'
  properties: {
    addressPrefix: '10.0.0.0/24'
  }
}]

param virtualMachineName string = 'vmfleetcommander'
param virtualMachineComputerName string = 'vmfleetcommand'
param osDiskType string = 'Premium_LRS'
param osDiskDeleteOption string = 'Delete'
param virtualMachineSize string = 'Standard_B1s'
param nicDeleteOption string = 'Detach'
param adminUsername string = 'gustavboyd'
param patchMode string = 'AutomaticByOS'
param enableHotpatching bool = false

@secure()
param adminPassword string

module virtualNetwork 'modules/virtualNetwork.bicep' = {
  name: 'virtualNetwork'
  params: {
    addressPrefixes: addressPrefixes
    location: location
    networkInterfaceName: networkInterfaceName
    networkSecurityGroupName: networkSecurityGroupName
    networkSecurityGroupRules: networkSecurityGroupRules
    subnetName: subnetName
    subnets: subnets
    virtualNetworkName: virtualNetworkName
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: virtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
        deleteOption: osDiskDeleteOption
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-datacenter-gensecond'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: virtualNetwork.outputs.virtualNetworkId
          properties: {
            deleteOption: nicDeleteOption
          }
        }
      ]
    }
    additionalCapabilities: {
      hibernationEnabled: false
    }
    osProfile: {
      computerName: virtualMachineComputerName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
        patchSettings: {
          enableHotpatching: enableHotpatching
          patchMode: patchMode
        }
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

output adminUsername string = adminUsername
