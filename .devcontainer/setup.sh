#!/bin/bash

# Exit on any error
set -e

echo "🚀 Setting up Azure Development Environment..."

# Update package list
sudo apt-get update

# Install additional dependencies
sudo apt-get install -y \
    curl \
    wget \
    unzip \
    jq \
    ca-certificates \
    gnupg \
    lsb-release

# Install Bicep
echo "📦 Installing Bicep..."
curl -Lo bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64
chmod +x ./bicep
sudo mv ./bicep /usr/local/bin/bicep

# Install Azure PowerShell modules
echo "🔧 Installing Azure PowerShell modules..."
pwsh -Command "Install-Module -Name Az -Repository PSGallery -Force -AllowClobber"
pwsh -Command "Install-Module -Name Az.Bicep -Repository PSGallery -Force -AllowClobber"

# Create Azure config directory if it doesn't exist
mkdir -p /home/vscode/.azure

# Set proper permissions
sudo chown -R vscode:vscode /home/vscode/.azure

# Create a helper script for service principal login
cat > /home/vscode/login-with-sp.sh << 'EOF'
#!/bin/bash

# Check if required environment variables are set
if [ -z "$AZURE_CLIENT_ID" ] || [ -z "$AZURE_CLIENT_SECRET" ] || [ -z "$AZURE_TENANT_ID" ]; then
    echo "❌ Error: Required environment variables not set."
    echo "Please set the following environment variables:"
    echo "  - AZURE_CLIENT_ID (Service Principal Client ID)"
    echo "  - AZURE_CLIENT_SECRET (Service Principal Client Secret)"
    echo "  - AZURE_TENANT_ID (Azure Tenant ID)"
    echo ""
    echo "You can also set AZURE_SUBSCRIPTION_ID if you want to set a default subscription."
    exit 1
fi

echo "🔐 Logging in with Service Principal..."

# Login with service principal
az login --service-principal \
    --username "$AZURE_CLIENT_ID" \
    --password "$AZURE_CLIENT_SECRET" \
    --tenant "$AZURE_TENANT_ID"

# Set subscription if provided
if [ ! -z "$AZURE_SUBSCRIPTION_ID" ]; then
    echo "📋 Setting subscription to: $AZURE_SUBSCRIPTION_ID"
    az account set --subscription "$AZURE_SUBSCRIPTION_ID"
fi

# Show current account info
echo "✅ Login successful!"
echo "Current account:"
az account show --query "{name:name, id:id, tenantId:tenantId}" -o table
EOF

chmod +x /home/vscode/login-with-sp.sh

# Create PowerShell version of the login script
cat > /home/vscode/login-with-sp.ps1 << 'EOF'
# Check if required environment variables are set
if (-not $env:AZURE_CLIENT_ID -or -not $env:AZURE_CLIENT_SECRET -or -not $env:AZURE_TENANT_ID) {
    Write-Host "❌ Error: Required environment variables not set." -ForegroundColor Red
    Write-Host "Please set the following environment variables:" -ForegroundColor Yellow
    Write-Host "  - AZURE_CLIENT_ID (Service Principal Client ID)" -ForegroundColor Yellow
    Write-Host "  - AZURE_CLIENT_SECRET (Service Principal Client Secret)" -ForegroundColor Yellow
    Write-Host "  - AZURE_TENANT_ID (Azure Tenant ID)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "You can also set AZURE_SUBSCRIPTION_ID if you want to set a default subscription." -ForegroundColor Yellow
    exit 1
}

Write-Host "🔐 Logging in with Service Principal..." -ForegroundColor Green

# Login with service principal
Connect-AzAccount -ServicePrincipal `
    -ApplicationId $env:AZURE_CLIENT_ID `
    -Credential (New-Object PSCredential($env:AZURE_CLIENT_ID, (ConvertTo-SecureString $env:AZURE_CLIENT_SECRET -AsPlainText -Force))) `
    -Tenant $env:AZURE_TENANT_ID

# Set subscription if provided
if ($env:AZURE_SUBSCRIPTION_ID) {
    Write-Host "📋 Setting subscription to: $env:AZURE_SUBSCRIPTION_ID" -ForegroundColor Green
    Set-AzContext -SubscriptionId $env:AZURE_SUBSCRIPTION_ID
}

# Show current account info
Write-Host "✅ Login successful!" -ForegroundColor Green
Write-Host "Current account:" -ForegroundColor Green
Get-AzContext | Select-Object Name, Account, Subscription, Tenant | Format-Table
EOF

# Create a .env.example file
cat > /home/vscode/.env.example << 'EOF'
# Azure Service Principal Configuration
# Copy this file to .env and fill in your values

# Required: Service Principal Client ID
AZURE_CLIENT_ID=your-service-principal-client-id

# Required: Service Principal Client Secret
AZURE_CLIENT_SECRET=your-service-principal-client-secret

# Required: Azure Tenant ID
AZURE_TENANT_ID=your-azure-tenant-id

# Optional: Azure Subscription ID (if you want to set a default subscription)
AZURE_SUBSCRIPTION_ID=your-subscription-id

# Optional: Azure Resource Group (for convenience)
AZURE_RESOURCE_GROUP=your-resource-group-name

# Optional: Azure Location (for convenience)
AZURE_LOCATION=eastus
EOF

# Create a README for the dev container
cat > /home/vscode/README.md << 'EOF'
# Azure Development Container

This dev container is configured with Azure CLI, Azure PowerShell, and Bicep for Azure development.

## 🛠️ Installed Tools

- **Azure CLI**: Latest version
- **Azure PowerShell**: Latest version with Az modules
- **Bicep**: Latest version
- **Git**: Latest version

## 🔐 Authentication

### Using Service Principal

1. Set up your environment variables:
   ```bash
   cp .env.example .env
   # Edit .env with your service principal details
   ```

2. Login using the provided script:
   ```bash
   # Using bash
   ./login-with-sp.sh

   # Using PowerShell
   pwsh -File login-with-sp.ps1
   ```

### Required Environment Variables

- `AZURE_CLIENT_ID`: Your service principal client ID
- `AZURE_CLIENT_SECRET`: Your service principal client secret
- `AZURE_TENANT_ID`: Your Azure tenant ID
- `AZURE_SUBSCRIPTION_ID`: (Optional) Your Azure subscription ID

## 📁 Useful Commands

```bash
# Check Azure CLI version
az version

# Check Bicep version
bicep --version

# Check PowerShell version
pwsh --version

# List Azure subscriptions
az account list

# Get current context
az account show
```

## 🔧 VS Code Extensions

The following extensions are automatically installed:
- Azure CLI Tools
- PowerShell
- Bicep
- Docker
- JSON Tools

## 📝 Notes

- Azure configuration is persisted in `/home/vscode/.azure`
- The container mounts your local Azure config directory for persistence
- Both bash and PowerShell terminals are available
EOF

echo "✅ Setup complete!"
echo ""
echo "🔧 Available tools:"
echo "  - Azure CLI: $(az version --query 'azure-cli' -o tsv)"
echo "  - Bicep: $(bicep --version)"
echo "  - PowerShell: $(pwsh --version)"
echo ""
echo "📖 Check /home/vscode/README.md for usage instructions"
echo "🔐 Use ./login-with-sp.sh to authenticate with your service principal"
