param location string
param networkInterfaceName string 
param networkSecurityGroupName string
param networkSecurityGroupRules array
param subnetName string
param virtualNetworkName string 
param addressPrefixes array
param subnets array

var nsgID = resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', networkSecurityGroupName)
var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)

module networkSecurityGroup 'networkSecurityGroup.bicep' = {
  name: 'networkSecurityGroup'
  params: {
    location: location
    networkSecurityGroupName: networkSecurityGroupName
    networkSecurityGroupRules: networkSecurityGroupRules
  }
}

module virtualNetwork 'virtualNetwork.bicep' = {
  name: 'virtualNetwork'
  params: {
    addressPrefixes: addressPrefixes
    location: location
    subnets: subnets
    virtualNetworkName: virtualNetworkName
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

output virtualNetworkId string = networkInterface.id
