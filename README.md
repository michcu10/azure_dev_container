# Azure Development Container

This repository contains a development container configuration for Azure development with Azure CLI, Azure PowerShell, and Bicep pre-installed.

## 🚀 Quick Start

### Prerequisites

- [Docker](https://www.docker.com/products/docker-desktop/) installed and running
- [VS Code](https://code.visualstudio.com/) with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- An Azure service principal for authentication

### Getting Started

1. **Clone or open this repository in VS Code**

2. **Create a service principal** (if you don't have one):

   **Option A: Use the provided script (Recommended)**
   ```bash
   chmod +x create-service-principal.sh
   ./create-service-principal.sh -s YOUR_SUBSCRIPTION_ID
   ```

   **Option B: Manual creation**
   ```bash
   # Get your subscription ID first
   az account show --query id -o tsv

   # Create service principal with subscription scope
   az ad sp create-for-rbac \
     --name "dev-container-sp" \
     --role "Contributor" \
     --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID"
   ```
   Save the output - you'll need the `appId`, `password`, and `tenant` values.

3. **Open in Dev Container**:
   - Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
   - Select "Dev Containers: Reopen in Container"
   - Wait for the container to build and start

4. **Set up authentication**:
   ```bash
   # Copy the example environment file
   cp .env.example .env

   # Edit .env with your service principal details
   nano .env
   ```

5. **Authenticate with Azure**:
   ```bash
   # Using bash
   ./login-with-sp.sh

   # Or using PowerShell
   pwsh -File login-with-sp.ps1
   ```

## 🛠️ What's Included

### Tools
- **Azure CLI**: Latest version for Azure resource management
- **Azure PowerShell**: Latest version with Az modules
- **Bicep**: Latest version for Infrastructure as Code
- **Git**: For version control
- **jq**: For JSON processing
- **curl/wget**: For downloading files

### VS Code Extensions
- Azure CLI Tools
- PowerShell
- Bicep
- Docker
- JSON Tools

### Authentication Scripts
- `login-with-sp.sh`: Bash script for service principal authentication
- `login-with-sp.ps1`: PowerShell script for service principal authentication

## 🔐 Service Principal Setup

### Creating a Service Principal

```bash
# Create a service principal with Contributor role on a specific subscription
az ad sp create-for-rbac \
  --name "dev-container-sp" \
  --role "Contributor" \
  --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID"

# Create a service principal with Contributor role on a specific resource group
az ad sp create-for-rbac \
  --name "dev-container-sp" \
  --role "Contributor" \
  --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RESOURCE_GROUP"

# Create a service principal with Reader role on a subscription (more restrictive)
az ad sp create-for-rbac \
  --name "dev-container-sp-reader" \
  --role "Reader" \
  --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID"
```

### Required Permissions

The service principal needs at least the following permissions:
- **Contributor** role on the subscription or resource groups you'll be working with
- **User.Read** permission on Azure AD (for authentication)

### Scope Examples

**Subscription Scope** (recommended for development):
```bash
--scopes "/subscriptions/12345678-1234-1234-1234-123456789012"
```

**Resource Group Scope** (more restrictive):
```bash
--scopes "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/my-dev-rg"
```

**Multiple Resource Groups**:
```bash
--scopes "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/my-dev-rg" "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/my-test-rg"
```

### Environment Variables

Create a `.env` file in the container with:

```bash
# Required
AZURE_CLIENT_ID=your-service-principal-client-id
AZURE_CLIENT_SECRET=your-service-principal-client-secret
AZURE_TENANT_ID=your-azure-tenant-id

# Optional
AZURE_SUBSCRIPTION_ID=your-subscription-id
AZURE_RESOURCE_GROUP=your-resource-group-name
AZURE_LOCATION=eastus
```

## 📁 Project Structure

```
azure_dev_container/
├── .devcontainer/
│   ├── devcontainer.json    # Main dev container configuration
│   └── setup.sh            # Setup script for tools and environment
├── README.md               # This file
└── .env.example           # Example environment variables
```

## 🔧 Common Commands

### Azure CLI
```bash
# Check version
az version

# List subscriptions
az account list

# Set subscription
az account set --subscription "Your Subscription Name"

# List resource groups
az group list

# Deploy Bicep template
az deployment group create --resource-group my-rg --template-file main.bicep
```

### Bicep
```bash
# Check version
bicep --version

# Build Bicep file
bicep build main.bicep

# Validate Bicep file
bicep lint main.bicep
```

### PowerShell
```powershell
# Check Azure PowerShell version
Get-Module -Name Az -ListAvailable

# Connect to Azure
Connect-AzAccount

# Get current context
Get-AzContext

# List resource groups
Get-AzResourceGroup
```

## 🐛 Troubleshooting

### Container Build Issues
- Ensure Docker is running
- Check that you have sufficient disk space
- Try rebuilding the container: `Ctrl+Shift+P` → "Dev Containers: Rebuild Container"

### Authentication Issues
- Verify your service principal credentials are correct
- Check that the service principal hasn't expired
- Ensure the service principal has the necessary permissions

### Tool Installation Issues
- The setup script runs automatically when the container starts
- You can manually run it: `bash .devcontainer/setup.sh`

## 🔒 Security Notes

- Never commit your `.env` file with real credentials
- Use environment variables or Azure Key Vault for production secrets
- Consider using managed identities for production workloads
- Regularly rotate your service principal secrets

## 📚 Additional Resources

- [Azure CLI Documentation](https://docs.microsoft.com/en-us/cli/azure/)
- [Azure PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/azure/)
- [Bicep Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Dev Containers Documentation](https://code.visualstudio.com/docs/devcontainers/containers)

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This project is licensed under the MIT License.
