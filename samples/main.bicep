@description('The name of the resource group')
param resourceGroupName string = resourceGroup().name

@description('The location for all resources')
param location string = resourceGroup().location

@description('The name of the storage account')
param storageAccountName string = 'st${uniqueString(resourceGroup().id)}'

@description('The name of the app service plan')
param appServicePlanName string = 'asp-${uniqueString(resourceGroup().id)}'

@description('The name of the web app')
param webAppName string = 'web-${uniqueString(resourceGroup().id)}'

@description('The SKU for the app service plan')
@allowed(['F1', 'B1', 'B2', 'B3', 'S1', 'S2', 'S3', 'P1V2', 'P2V2', 'P3V2'])
param appServicePlanSku string = 'F1'

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSku
  }
  properties: {
    reserved: false
  }
}

// Web App
resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'AzureWebJobsStorage'
          value: storageAccount.properties.primaryEndpoints.blob
        }
      ]
    }
  }
}

// Outputs
output storageAccountName string = storageAccount.name
output storageAccountKey string = storageAccount.listKeys().keys[0].value
output webAppName string = webApp.name
output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
