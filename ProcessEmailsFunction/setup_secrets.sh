#!/bin/bash
# Script to set up the necessary secrets in Secret Manager

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ID="dispatch-dashboard-01"

echo -e "${GREEN}Setting up Secret Manager secrets for the Process Emails Cloud Function...${NC}"

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}Error: gcloud CLI is not installed. Please install it first.${NC}"
    echo "Visit https://cloud.google.com/sdk/docs/install for installation instructions."
    exit 1
fi

# Check if the user is logged in
gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q "@"
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: You are not logged in to gcloud. Please run 'gcloud auth login' first.${NC}"
    exit 1
fi

# Check if the project exists
gcloud projects describe $PROJECT_ID &> /dev/null
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Project $PROJECT_ID does not exist or you don't have access to it.${NC}"
    exit 1
fi

# Enable Secret Manager API
echo "Enabling Secret Manager API..."
gcloud services enable secretmanager.googleapis.com --project=$PROJECT_ID

# 1. Set up Gmail API credentials secret
echo -e "\n${YELLOW}Setting up Gmail API credentials secret...${NC}"
echo "Please provide the path to your Gmail API credentials JSON file:"
read -p "Path: " GMAIL_CREDS_PATH

if [ ! -f "$GMAIL_CREDS_PATH" ]; then
    echo -e "${RED}Error: File not found at $GMAIL_CREDS_PATH${NC}"
    exit 1
fi

echo "Creating gmail-docai-credentials secret..."
gcloud secrets create gmail-docai-credentials \
    --data-file="$GMAIL_CREDS_PATH" \
    --project=$PROJECT_ID

if [ $? -ne 0 ]; then
    echo -e "${RED}Error creating gmail-docai-credentials secret.${NC}"
    exit 1
fi

# 2. Set up Document AI credentials secret
echo -e "\n${YELLOW}Setting up Document AI credentials secret...${NC}"
echo "Please provide the path to your Document AI credentials JSON file:"
read -p "Path: " DOCAI_CREDS_PATH

if [ ! -f "$DOCAI_CREDS_PATH" ]; then
    echo -e "${RED}Error: File not found at $DOCAI_CREDS_PATH${NC}"
    exit 1
fi

echo "Creating docai-credentials secret..."
gcloud secrets create docai-credentials \
    --data-file="$DOCAI_CREDS_PATH" \
    --project=$PROJECT_ID

if [ $? -ne 0 ]; then
    echo -e "${RED}Error creating docai-credentials secret.${NC}"
    exit 1
fi

# 3. Set up database password secret
echo -e "\n${YELLOW}Setting up database password secret...${NC}"
echo "Please enter your database password:"
read -s -p "Password: " DB_PASSWORD
echo

echo "Creating db-password secret..."
echo -n "$DB_PASSWORD" | gcloud secrets create db-password \
    --data-file=- \
    --project=$PROJECT_ID

if [ $? -ne 0 ]; then
    echo -e "${RED}Error creating db-password secret.${NC}"
    exit 1
fi

echo -e "\n${GREEN}All secrets have been created successfully!${NC}"
echo "You can now proceed with deploying the Cloud Function."
