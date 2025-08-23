# Using Azure Dev Container for Remote Bicep Development

## 🎯 Option 3: Remote Development Environment

You can use this Azure dev container as a remote development environment and mount your Bicep repository into it.

### Step 1: Clone This Container Repository

```bash
git clone <this-repo-url> azure-dev-container
cd azure-dev-container
```

### Step 2: Mount Your Bicep Repository

Create a `docker-compose.override.yml` file to mount your Bicep repository:

```yaml
version: '3.8'
services:
  app:
    volumes:
      # Mount your Bicep repository
      - /path/to/your/bicep-repo:/workspaces/bicep-repo:cached
      # Mount additional directories if needed
      - /path/to/other/projects:/workspaces/other-projects:cached
```

### Step 3: Start the Container

```bash
# Using Docker Compose
docker-compose up -d

# Or using VS Code Dev Containers
# Open the azure-dev-container folder in VS Code
# Press Ctrl+Shift+P → "Dev Containers: Reopen in Container"
```

### Step 4: Access Your Bicep Repository

Once the container is running, your Bicep repository will be available at `/workspaces/bicep-repo` with all the Azure tools pre-installed.

## 🔧 Alternative: Use VS Code Remote Development

### Option A: Remote-SSH with Container

1. **Set up SSH access** to a machine with Docker
2. **Install the dev container** on that machine
3. **Use VS Code Remote-SSH** to connect
4. **Mount your Bicep repository** into the container

### Option B: GitHub Codespaces

1. **Push this dev container** to a GitHub repository
2. **Create a Codespace** from that repository
3. **Clone your Bicep repository** into the Codespace
4. **Use the pre-configured Azure environment**

## 📁 Recommended Bicep Repository Structure

When using the dev container, organize your Bicep repository like this:

```
your-bicep-repo/
├── modules/                    # Reusable Bicep modules
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
├── environments/               # Environment-specific deployments
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
├── scripts/                   # Utility scripts
│   ├── validate-all.sh
│   ├── deploy-all.sh
│   └── cleanup.sh
├── docs/                      # Documentation
│   ├── architecture.md
│   ├── deployment-guide.md
│   └── troubleshooting.md
└── .devcontainer/             # Dev container config (if using Option 1)
    ├── devcontainer.json
    └── setup.sh
```

## 🚀 Quick Start Commands

Once your Bicep repository is mounted in the container:

```bash
# Navigate to your Bicep repository
cd /workspaces/bicep-repo

# Set up authentication
cp env.example .env
nano .env  # Add your service principal details
source .env
./login-with-sp.sh

# Validate your Bicep templates
find . -name "*.bicep" -exec bicep build {} \;

# Deploy to dev environment
cd environments/dev
./deploy.sh
```

## 🔧 Development Workflow

1. **Edit Bicep templates** in your mounted repository
2. **Use the container's Azure tools** for validation and deployment
3. **Test changes** in the dev environment
4. **Commit and push** changes to your repository
5. **Use CI/CD** to deploy to staging/prod

## 💡 Tips for Remote Development

- **Use VS Code's Remote Development** extension for seamless editing
- **Set up Git credentials** in the container for easy commits
- **Use environment variables** for different Azure subscriptions
- **Leverage the container's persistent Azure configuration**
- **Use the included scripts** for common tasks
