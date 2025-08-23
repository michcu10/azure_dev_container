# My Azure Bicep Infrastructure Repository

This repository contains Azure Bicep templates for deploying infrastructure components.

## 🚀 Development Environment

This project uses a dev container with Azure CLI, PowerShell, and Bicep pre-installed.

### Quick Start

1. **Clone this repository**
2. **Create a service principal** (if you don't have one):
   ```bash
   # Get your subscription ID first
   az account show --query id -o tsv

   # Create service principal with subscription scope
   az ad sp create-for-rbac \
     --name "dev-container-sp" \
     --role "Contributor" \
     --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID"
   ```
3. **Open in VS Code** with Dev Containers extension
4. **Reopen in Container** (`Ctrl+Shift+P` → "Dev Containers: Reopen in Container")
5. **Set up authentication**:
   ```bash
   cp env.example .env
   # Edit .env with your service principal details
   ./login-with-sp.sh
   ```

## 📁 Project Structure

```
├── .devcontainer/          # Dev container configuration
├── .vscode/               # VS Code settings
├── modules/               # Reusable Bicep modules
│   ├── networking/
│   ├── compute/
│   └── storage/
├── environments/          # Environment-specific deployments
│   ├── dev/
│   ├── staging/
│   └── prod/
├── scripts/              # Deployment and utility scripts
└── docs/                 # Documentation
```

## 🔧 Development Workflow

1. **Create/Edit Bicep templates** in the appropriate directories
2. **Test locally** using the dev container tools
3. **Deploy to dev environment** for testing
4. **Promote to staging/prod** through your CI/CD pipeline

## 📚 Documentation

- [Bicep Best Practices](./docs/best-practices.md)
- [Module Documentation](./docs/modules.md)
- [Deployment Guide](./docs/deployment.md)
