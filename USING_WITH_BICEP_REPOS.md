# Using Azure Dev Container with Bicep Repositories

This guide shows you how to use this Azure dev container with your own Bicep deployment repositories.

## 🎯 Overview

You have several options for developing Azure Bicep templates while leveraging this pre-configured development environment:

1. **Copy the container to your repo** (Recommended for new projects)
2. **Use as a base image** (Good for existing projects)
3. **Mount your repo into the container** (Best for quick development)
4. **Use with Docker Compose** (Most flexible)

## 🚀 Option 1: Copy Container to Your Repo (Recommended)

### Best For: New Bicep projects or when you want full control

**Steps:**

1. **Copy these files** to your Bicep repository:
   ```bash
   cp -r .devcontainer/ /path/to/your/bicep-repo/
   cp -r .vscode/ /path/to/your/bicep-repo/
   cp env.example /path/to/your/bicep-repo/
   cp .gitignore /path/to/your/bicep-repo/
   ```

2. **Customize the container** for your project:
   ```json
   // .devcontainer/devcontainer.json
   {
     "name": "My Bicep Project",
     // ... rest of config
   }
   ```

3. **Open in VS Code** and select "Reopen in Container"

**Pros:**
- ✅ Full control over the environment
- ✅ Project-specific customizations
- ✅ Easy to share with team members
- ✅ Works with any CI/CD pipeline

**Cons:**
- ❌ Need to maintain container configuration
- ❌ Larger repository size

## 🔧 Option 2: Use as Base Image

### Best For: Existing projects that need Azure tools

**Steps:**

1. **Create a new dev container** in your repo:
   ```json
   // .devcontainer/devcontainer.json
   {
     "name": "Azure Bicep Development",
     "image": "mcr.microsoft.com/devcontainers/base:ubuntu-22.04",
     "features": {
       "ghcr.io/devcontainers/features/azure-cli:1": {
         "version": "latest"
       },
       "ghcr.io/devcontainers/features/powershell:1": {
         "version": "latest"
       }
     },
     "customizations": {
       "vscode": {
         "extensions": [
           "ms-azuretools.vscode-bicep",
           "ms-vscode.azurecli",
           "ms-vscode.powershell"
         ]
       }
     },
     "postCreateCommand": "bash .devcontainer/setup.sh"
   }
   ```

2. **Copy the setup script** from this project

**Pros:**
- ✅ Lightweight approach
- ✅ Uses official dev container features
- ✅ Easy to customize

**Cons:**
- ❌ Need to maintain setup script
- ❌ Less integrated than full copy

## 📁 Option 3: Mount Your Repo (Quick Development)

### Best For: Quick development sessions or testing

**Steps:**

1. **Clone this container repo:**
   ```bash
   git clone <this-repo-url> azure-dev-container
   cd azure-dev-container
   ```

2. **Mount your Bicep repo:**
   ```bash
   # Create a symlink or mount point
   ln -s /path/to/your/bicep-repo ./bicep-repo
   ```

3. **Start the container:**
   ```bash
   # Using VS Code
   # Open azure-dev-container folder
   # Press Ctrl+Shift+P → "Dev Containers: Reopen in Container"
   ```

**Pros:**
- ✅ No changes to your repo needed
- ✅ Quick setup
- ✅ Isolated development environment

**Cons:**
- ❌ More complex setup
- ❌ Need to manage multiple repos

## 🐳 Option 4: Docker Compose (Most Flexible)

### Best For: Complex setups or multiple repositories

**Steps:**

1. **Use the provided Docker Compose setup:**
   ```bash
   # Make the script executable
   chmod +x start-dev-container.sh

   # Start with your Bicep repo
   ./start-dev-container.sh -r /path/to/your/bicep-repo
   ```

2. **Connect to the container:**
   ```bash
   docker exec -it azure-dev-container bash
   ```

**Pros:**
- ✅ Most flexible
- ✅ Can mount multiple repos
- ✅ Easy to script and automate
- ✅ Works with any IDE

**Cons:**
- ❌ Requires Docker knowledge
- ❌ More complex than VS Code dev containers

## 📋 Recommended Bicep Repository Structure

When using any of these options, organize your Bicep repository like this:

```
your-bicep-repo/
├── .devcontainer/              # Dev container config (Option 1)
├── .vscode/                   # VS Code settings (Option 1)
├── modules/                   # Reusable Bicep modules
│   ├── networking/
│   │   ├── vnet.bicep
│   │   ├── subnet.bicep
│   │   └── nsg.bicep
│   ├── compute/
│   │   ├── vm.bicep
│   │   └── vmss.bicep
│   └── storage/
│       ├── storage-account.bicep
│       └── container.bicep
├── environments/              # Environment-specific deployments
│   ├── dev/
│   │   ├── main.bicep
│   │   ├── parameters.json
│   │   └── deploy.sh
│   ├── staging/
│   │   ├── main.bicep
│   │   ├── parameters.json
│   │   └── deploy.sh
│   └── prod/
│       ├── main.bicep
│       ├── parameters.json
│       └── deploy.sh
├── scripts/                  # Utility scripts
│   ├── validate-all.sh
│   ├── deploy-all.sh
│   └── cleanup.sh
├── docs/                     # Documentation
│   ├── architecture.md
│   ├── deployment-guide.md
│   └── troubleshooting.md
├── .gitignore               # Git ignore rules
└── env.example              # Environment variables template
```

## 🔐 Service Principal Setup

Before using the dev container, you need to create a service principal with the correct scope:

### 1. Get Your Subscription ID
```bash
az account show --query id -o tsv
```

### 2. Create Service Principal with Subscription Scope (Recommended)
```bash
az ad sp create-for-rbac \
  --name "dev-container-sp" \
  --role "Contributor" \
  --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID"
```

### 3. Create Service Principal with Resource Group Scope (More Restrictive)
```bash
az ad sp create-for-rbac \
  --name "dev-container-sp" \
  --role "Contributor" \
  --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RESOURCE_GROUP"
```

### 4. Save the Output
The command will output JSON with your credentials:
```json
{
  "appId": "12345678-1234-1234-1234-123456789012",
  "displayName": "dev-container-sp",
  "password": "your-secret-password",
  "tenant": "12345678-1234-1234-1234-123456789012"
}
```

## 🚀 Quick Start Commands

Once your Bicep repository is set up with the dev container:

```bash
# Navigate to your Bicep repository
cd /workspaces/bicep-repo  # or your repo path

# Set up authentication
cp env.example .env
nano .env  # Add your service principal details
source .env
./login-with-sp.sh

# Note: Make sure your service principal was created with the correct scope:
# az ad sp create-for-rbac --name "dev-container-sp" --role "Contributor" --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID"

# Validate all Bicep templates
find . -name "*.bicep" -exec bicep build {} \;

# Deploy to dev environment
cd environments/dev
./deploy.sh

# Check Azure resources
az group list
az resource list --resource-group your-rg-name
```

## 🔧 Development Workflow

### 1. **Development Phase**
- Edit Bicep templates in your repository
- Use the container's tools for validation
- Test locally with `bicep build` and `bicep lint`

### 2. **Testing Phase**
- Deploy to dev environment
- Validate the deployment
- Test functionality

### 3. **Promotion Phase**
- Commit and push changes
- Use CI/CD to deploy to staging/prod
- Monitor deployments

### 4. **Maintenance Phase**
- Update templates as needed
- Rotate service principal secrets
- Keep tools updated

## 💡 Best Practices

### Security
- **Never commit `.env` files** with real credentials
- **Use Azure Key Vault** for production secrets
- **Rotate service principal secrets** regularly
- **Use least-privilege permissions** for service principals

### Development
- **Use modules** for reusable components
- **Parameterize everything** that might change
- **Use consistent naming conventions**
- **Document your templates** with comments

### Organization
- **Separate environments** (dev/staging/prod)
- **Use version control** for all templates
- **Tag your deployments** for tracking
- **Keep templates modular** and focused

## 🐛 Troubleshooting

### Common Issues

1. **Container won't start**
   - Check Docker is running
   - Verify sufficient disk space
   - Check Docker logs: `docker-compose logs`

2. **Authentication fails**
   - Verify service principal credentials
   - Check subscription permissions
   - Ensure tenant ID is correct

3. **Bicep validation errors**
   - Run `bicep build` to see detailed errors
   - Check API versions are current
   - Verify resource provider registrations

4. **Deployment fails**
   - Check resource quotas
   - Verify resource names are unique
   - Review Azure activity logs

### Getting Help

- **Check the logs**: `docker-compose logs azure-dev`
- **Validate templates**: `bicep build --stdout`
- **Test deployments**: `az deployment group what-if`
- **Review documentation**: Check the `/docs` folder

## 📚 Additional Resources

- [Bicep Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Dev Containers Documentation](https://code.visualstudio.com/docs/devcontainers/containers)
- [Azure CLI Documentation](https://docs.microsoft.com/en-us/cli/azure/)
- [Azure PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/azure/)

## 🤝 Contributing

Feel free to:
- Submit issues for problems you encounter
- Suggest improvements to the container setup
- Share your Bicep templates and scripts
- Contribute to the documentation
