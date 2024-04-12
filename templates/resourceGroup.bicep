targetScope = 'subscription'

param rgName string = 'testvmcommander'
param rgLocation string = deployment().location


resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgName
  location: rgLocation
}
