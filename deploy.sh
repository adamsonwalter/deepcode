#!/bin/bash

# DeepCode - Google Cloud Run Deployment Script
# This script helps you deploy DeepCode to Google Cloud Run

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SERVICE_NAME="deepcode-service"
REGION="us-central1"
MEMORY="2Gi"
CPU="2"
MAX_INSTANCES="10"

echo -e "${BLUE}🚀 DeepCode - Google Cloud Run Deployment${NC}"
echo "=============================================="

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}❌ Google Cloud CLI (gcloud) is not installed${NC}"
    echo -e "${YELLOW}Please install it from: https://cloud.google.com/sdk/docs/install${NC}"
    exit 1
fi

# Check if logged in
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -1 &> /dev/null; then
    echo -e "${YELLOW}⚠️  Not logged in to Google Cloud${NC}"
    echo -e "${BLUE}Logging in...${NC}"
    gcloud auth login
fi

# Get current project
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}❌ No project set${NC}"
    echo -e "${YELLOW}Please set your project: gcloud config set project YOUR_PROJECT_ID${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Using project: ${PROJECT_ID}${NC}"

# Enable required APIs
echo -e "${BLUE}🔧 Enabling required APIs...${NC}"
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com

# Build and deploy
echo -e "${BLUE}🏗️  Building and deploying to Cloud Run...${NC}"

# Method 1: Direct deployment (recommended for first-time deployment)
echo -e "${BLUE}📦 Building container image...${NC}"
gcloud builds submit --tag gcr.io/$PROJECT_ID/deepcode .

echo -e "${BLUE}🚢 Deploying to Cloud Run...${NC}"
gcloud run deploy $SERVICE_NAME \
    --image gcr.io/$PROJECT_ID/deepcode \
    --platform managed \
    --region $REGION \
    --allow-unauthenticated \
    --port 8080 \
    --memory $MEMORY \
    --cpu $CPU \
    --timeout 900 \
    --concurrency 10 \
    --max-instances $MAX_INSTANCES \
    --set-env-vars PYTHONPATH=/app

# Get the service URL
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --platform managed --region $REGION --format 'value(status.url)')

echo ""
echo -e "${GREEN}🎉 Deployment successful!${NC}"
echo -e "${BLUE}📍 Service URL: ${SERVICE_URL}${NC}"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo "1. Set up your API keys in Cloud Run environment variables:"
echo "   - Go to Cloud Console > Cloud Run > $SERVICE_NAME > Edit & Deploy New Revision"
echo "   - Add environment variables for your API keys"
echo "2. Your DeepCode application is now live at: $SERVICE_URL"
echo ""
echo -e "${BLUE}💡 To update your deployment:${NC}"
echo "   ./deploy.sh"
echo ""
echo -e "${GREEN}Happy coding! 🧬${NC}"
