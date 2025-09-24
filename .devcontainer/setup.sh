#!/bin/bash

# Contoso Sales Assistant - Development Environment Setup Script
echo "🚀 Setting up Contoso Sales Assistant development environment..."

# Install Python dependencies
echo "📦 Installing Python dependencies..."
pip3 install --user -r requirements-dev.txt

# Generate default environment variables for Azure deployment
echo "🔐 Setting up default Azure deployment parameters..."

# Generate secure random secrets
CHAINLIT_AUTH_SECRET=$(openssl rand -base64 32)
LITERAL_API_KEY=$(openssl rand -base64 32)

# Create .env file with default values if it doesn't exist
if [ ! -f .env ]; then
    cat > .env << EOF
# Azure Deployment Configuration
# These values will be set automatically during deployment

# Generated secrets (do not modify manually)
CHAINLIT_AUTH_SECRET=${CHAINLIT_AUTH_SECRET}
LITERAL_API_KEY=${LITERAL_API_KEY}

# Azure OpenAI Configuration (will be populated during deployment)
AZURE_OPENAI_ENDPOINT=
AZURE_OPENAI_API_KEY=
AZURE_OPENAI_API_VERSION=2024-05-01-preview
AZURE_OPENAI_DEPLOYMENT=gpt-4o
AZURE_OPENAI_ASSISTANT_ID=

# Application Configuration
ASSISTANT_PASSWORD=
ENV=development
EOF
    echo "✅ Created .env file with default configuration"
else
    echo "ℹ️  .env file already exists, skipping creation"
fi

# Verify Azure CLI tools are available
echo "🔍 Verifying Azure CLI tools..."

if command -v az &> /dev/null; then
    echo "✅ Azure CLI (az) is available"
else
    echo "❌ Azure CLI (az) is not available"
fi

if command -v azd &> /dev/null; then
    echo "✅ Azure Developer CLI (azd) is available"
else
    echo "❌ Azure Developer CLI (azd) is not available"
fi

if command -v gh &> /dev/null; then
    echo "✅ GitHub CLI (gh) is available"
else
    echo "❌ GitHub CLI (gh) is not available"
fi

echo "🎉 Development environment setup completed!"
echo ""
echo "📋 Next steps:"
echo "1. Run 'az login --use-device-code' to login to Azure"
echo "2. Run 'azd auth login --use-device-code' to login to Azure Developer CLI"
echo "3. Run 'azd up' to deploy the application to Azure"
echo ""