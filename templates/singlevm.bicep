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

var nsgID = resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', networkSecurityGroupName)
var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2020-05-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: networkSecurityGroupRules
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: subnets
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2023-09-01' =  {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgID
    }
  }
  dependsOn: [
    networkSecurityGroup
    virtualNetwork
  ]
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
          id: networkInterface.id
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
