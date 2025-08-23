#!/bin/bash

# Script to start the Azure dev container with a Bicep repository

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo -e "${BLUE}Usage: $0 [OPTIONS]${NC}"
    echo ""
    echo "Options:"
    echo "  -r, --repo PATH    Path to your Bicep repository (required)"
    echo "  -a, --additional PATH  Path to additional repositories"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 -r /path/to/my-bicep-repo"
    echo "  $0 -r /path/to/my-bicep-repo -a /path/to/other-repos"
    exit 1
}

# Parse command line arguments
BICEP_REPO_PATH=""
ADDITIONAL_REPO_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--repo)
            BICEP_REPO_PATH="$2"
            shift 2
            ;;
        -a|--additional)
            ADDITIONAL_REPO_PATH="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            ;;
    esac
done

# Check if Bicep repository path is provided
if [ -z "$BICEP_REPO_PATH" ]; then
    echo -e "${RED}Error: Bicep repository path is required${NC}"
    usage
fi

# Check if the Bicep repository exists
if [ ! -d "$BICEP_REPO_PATH" ]; then
    echo -e "${RED}Error: Bicep repository path does not exist: $BICEP_REPO_PATH${NC}"
    exit 1
fi

# Convert to absolute path
BICEP_REPO_PATH=$(realpath "$BICEP_REPO_PATH")

echo -e "${GREEN}🚀 Starting Azure Dev Container...${NC}"
echo -e "${BLUE}📁 Bicep Repository: $BICEP_REPO_PATH${NC}"

if [ ! -z "$ADDITIONAL_REPO_PATH" ]; then
    ADDITIONAL_REPO_PATH=$(realpath "$ADDITIONAL_REPO_PATH")
    echo -e "${BLUE}📁 Additional Repositories: $ADDITIONAL_REPO_PATH${NC}"
fi

# Export environment variables for Docker Compose
export BICEP_REPO_PATH
export ADDITIONAL_REPO_PATH

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker and try again.${NC}"
    exit 1
fi

# Build and start the container
echo -e "${YELLOW}🔨 Building and starting container...${NC}"
docker-compose up -d --build

# Wait for container to be ready
echo -e "${YELLOW}⏳ Waiting for container to be ready...${NC}"
sleep 5

# Check if container is running
if docker ps | grep -q azure-dev-container; then
    echo -e "${GREEN}✅ Container is running successfully!${NC}"
    echo ""
    echo -e "${BLUE}🔧 Next steps:${NC}"
    echo "1. Connect to the container:"
    echo "   docker exec -it azure-dev-container bash"
    echo ""
    echo "2. Or use VS Code Remote Development:"
    echo "   - Install 'Remote - Containers' extension"
    echo "   - Open the container in VS Code"
    echo ""
    echo "3. Set up Azure authentication:"
    echo "   cp env.example .env"
    echo "   nano .env  # Add your service principal details"
    echo "   ./login-with-sp.sh"
    echo ""
    echo -e "${GREEN}🎉 Your Bicep repository is available at /workspaces/bicep-repo${NC}"
else
    echo -e "${RED}❌ Failed to start container. Check Docker logs:${NC}"
    docker-compose logs
    exit 1
fi
