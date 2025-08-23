# Sample Azure Resources

This directory contains sample Azure resources and deployment scripts to help you get started with the dev container.

## 📁 Contents

- `main.bicep` - Sample Bicep template that deploys a web app with storage
- `deploy.ps1` - PowerShell deployment script
- `deploy.sh` - Bash deployment script
- `README.md` - This documentation file

## 🚀 Quick Start

### Prerequisites

1. **Authenticate with Azure** using your service principal:
   ```bash
   # Using bash
   ./login-with-sp.sh

   # Using PowerShell
   pwsh -File login-with-sp.ps1
   ```

2. **Navigate to the samples directory**:
   ```bash
   cd samples
   ```

### Deploy Using PowerShell

```powershell
# Deploy with default settings (F1 SKU, eastus location)
pwsh -File deploy.ps1 -ResourceGroupName "my-sample-rg"

# Deploy with custom settings
pwsh -File deploy.ps1 -ResourceGroupName "my-sample-rg" -Location "westus2" -AppServicePlanSku "B1"
```

### Deploy Using Bash

```bash
# Make the script executable
chmod +x deploy.sh

# Deploy with default settings (F1 SKU, eastus location)
./deploy.sh -g "my-sample-rg"

# Deploy with custom settings
./deploy.sh -g "my-sample-rg" -l "westus2" -s "B1"
```

## 📋 What Gets Deployed

The sample Bicep template deploys the following Azure resources:

### 1. Storage Account
- **Type**: StorageV2
- **SKU**: Standard_LRS
- **Features**: HTTPS-only, TLS 1.2 minimum
- **Purpose**: Provides blob storage for the web app

### 2. App Service Plan
- **Type**: Consumption plan (serverless)
- **SKU**: Configurable (F1, B1, B2, B3, S1, S2, S3, P1V2, P2V2, P3V2)
- **Purpose**: Hosting plan for the web app

### 3. Web App
- **Type**: Azure Web App
- **Runtime**: Default (can be configured)
- **App Settings**:
  - `WEBSITE_RUN_FROM_PACKAGE`: Set to 1 for deployment optimization
  - `AzureWebJobsStorage`: Points to the storage account blob endpoint
- **Purpose**: Hosts your web application

## 🔧 Customization

### Modifying the Bicep Template

You can customize the `main.bicep` file to add more resources or modify existing ones:

```bicep
// Add a new resource
resource newResource 'Microsoft.YourProvider/yourResource@2023-01-01' = {
  name: 'my-resource-name'
  location: location
  properties: {
    // Your properties here
  }
}

// Reference the new resource
resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  // ... existing properties ...
  properties: {
    // ... existing properties ...
    siteConfig: {
      appSettings: [
        // ... existing settings ...
        {
          name: 'NEW_SETTING'
          value: newResource.properties.someProperty
        }
      ]
    }
  }
}
```

### Adding Parameters

To add new parameters to the template:

```bicep
@description('Your new parameter description')
param newParameter string = 'default-value'
```

### Adding Outputs

To expose new values from the deployment:

```bicep
output newOutput string = newResource.properties.someProperty
```

## 🧹 Cleanup

To clean up the deployed resources:

```bash
# Using Azure CLI
az group delete --name "my-sample-rg" --yes --no-wait

# Using PowerShell
Remove-AzResourceGroup -Name "my-sample-rg" -Force -AsJob
```

## 🔍 Troubleshooting

### Common Issues

1. **Authentication Errors**
   - Ensure you've run the login script first
   - Verify your service principal credentials are correct
   - Check that the service principal has Contributor permissions

2. **Resource Name Conflicts**
   - Azure resource names must be globally unique
   - The template uses `uniqueString()` to generate unique names
   - If you get a name conflict, try a different resource group name

3. **Quota Exceeded**
   - Check your Azure subscription quotas
   - Some regions may have different limits
   - Consider using a different region or SKU

### Debugging

Enable verbose output for more detailed information:

```bash
# Azure CLI with verbose output
az deployment group create --verbose ...

# PowerShell with verbose output
New-AzResourceGroupDeployment -Verbose ...
```

### Validation

Validate your Bicep template before deployment:

```bash
# Validate the template
bicep build main.bicep

# Lint the template
bicep lint main.bicep

# What-if deployment (preview changes)
az deployment group what-if --resource-group "my-rg" --template-file main.bicep
```

## 📚 Next Steps

After successfully deploying the sample:

1. **Explore the Azure Portal** to see your deployed resources
2. **Deploy your own application** to the web app
3. **Add more resources** to the Bicep template
4. **Set up CI/CD** using GitHub Actions or Azure DevOps
5. **Implement monitoring** with Application Insights
6. **Add networking** with Virtual Networks and Application Gateways

## 🔗 Useful Links

- [Bicep Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Azure Web Apps Documentation](https://docs.microsoft.com/en-us/azure/app-service/)
- [Azure Storage Documentation](https://docs.microsoft.com/en-us/azure/storage/)
- [Azure CLI Documentation](https://docs.microsoft.com/en-us/cli/azure/)
- [Azure PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/azure/)
