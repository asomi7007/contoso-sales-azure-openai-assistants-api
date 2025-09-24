#!/bin/bash

# Contoso Sales Assistant - Azure Deployment Script
# This script automates the deployment process to Azure

set -e  # Exit on error

echo "🚀 Starting Contoso Sales Assistant deployment to Azure..."
echo ""



# Check if user is logged in to Azure CLI
echo "🔍 Checking Azure CLI authentication..."
if ! az account show &> /dev/null; then
    echo "❌ Not logged in to Azure CLI"
    echo "🔐 Please login to Azure CLI with device code..."
    az login --use-device-code
    echo "✅ Azure CLI login completed"
else
    echo "✅ Already logged in to Azure CLI"
    CURRENT_USER=$(az account show --query user.name -o tsv)
    echo "   Current user: $CURRENT_USER"
fi

# Check if user is logged in to Azure Developer CLI
echo ""
echo "🔍 Checking Azure Developer CLI authentication..."
if ! azd auth show &> /dev/null; then
    echo "❌ Not logged in to Azure Developer CLI"
    echo "🔐 Please login to Azure Developer CLI with device code..."
    azd auth login --use-device-code
    echo "✅ Azure Developer CLI login completed"
else
    echo "✅ Already logged in to Azure Developer CLI"
fi

# Check if user is logged in to Azure Developer CLI
echo ""
echo "🔍 Checking Azure Developer CLI authentication..."
if ! azd auth show &> /dev/null; then
    echo "❌ Not logged in to Azure Developer CLI"
    echo "🔐 Please login to Azure Developer CLI with device code..."
    azd auth login --use-device-code
    echo "✅ Azure Developer CLI login completed"
else
    echo "✅ Already logged in to Azure Developer CLI"
fi

# Check if azd environment exists, if not create one
echo ""
echo "🔍 Checking azd environment..."
if ! azd env list 2>/dev/null | grep -q "ContosoSalesAssistant"; then
    echo "⚙️  Creating new azd environment..."
    ENVIRONMENT_NAME="ContosoSalesAssistant$(date +%m%d)$(shuf -i 1000-9999 -n 1)"
    azd init --environment "$ENVIRONMENT_NAME"
    echo "✅ Created environment: $ENVIRONMENT_NAME"
else
    echo "✅ Using existing azd environment"
fi

# Set up environment variables for deployment
echo ""
echo "⚙️  Setting up deployment parameters..."

# Check if environment variables are already set
if [ -z "$CHAINLIT_AUTH_SECRET" ]; then
    export CHAINLIT_AUTH_SECRET=$(openssl rand -base64 32)
    echo "✅ Generated CHAINLIT_AUTH_SECRET"
fi

if [ -z "$LITERAL_API_KEY" ]; then
    export LITERAL_API_KEY=$(openssl rand -base64 32)
    echo "✅ Generated LITERAL_API_KEY"
fi

# Set azd environment variables
azd env set CHAINLIT_AUTH_SECRET "$CHAINLIT_AUTH_SECRET" > /dev/null 2>&1
azd env set LITERAL_API_KEY "$LITERAL_API_KEY" > /dev/null 2>&1

echo "🔧 Deployment parameters configured"
echo ""

# Start deployment
echo "🚀 Starting Azure deployment..."
echo "   This process may take 5-10 minutes..."
echo ""

# Deploy with azd up
if azd up --no-prompt; then
    echo ""
    echo "🎉 Deployment completed successfully!"
    echo ""
    
    # Get deployment outputs
    echo "📋 Deployment Information:"
    echo "=========================="
    
    SERVICE_URI=$(azd env get-value SERVICE_ACA_URI 2>/dev/null || echo "Not available")
    ASSISTANT_PASSWORD=$(azd env get-value assistantPassword 2>/dev/null || echo "Not available")
    AZURE_LOCATION=$(azd env get-value AZURE_LOCATION 2>/dev/null || echo "Not available")
    RESOURCE_GROUP=$(azd env get-value AZURE_OPENAI_RESOURCE_GROUP 2>/dev/null || echo "Not available")
    
    echo "🌐 Application URL: ${SERVICE_URI}/sales"
    echo "👤 Username: sales@contoso.com"
    echo "🔑 Password: password (fixed in code)"
    echo "📍 Azure Region: ${AZURE_LOCATION}"
    echo "📦 Resource Group: ${RESOURCE_GROUP}"
    echo ""
    echo "✨ Your Contoso Sales Assistant is now live at:"
    echo "   ${SERVICE_URI}/sales"
    echo ""
    echo "🔐 Login with:"
    echo "   Username: sales@contoso.com"
    echo "   Password: password (fixed in code)"
    echo ""
else
    echo ""
    echo "❌ Deployment failed!"
    echo "Please check the error messages above and try again."
    echo "You can run this script again or use 'azd up' directly."
    exit 1
fi