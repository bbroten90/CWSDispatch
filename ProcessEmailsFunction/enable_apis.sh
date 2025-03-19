#!/bin/bash
# Script to enable the necessary APIs in Google Cloud

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ID="dispatch-dashboard-01"

echo -e "${GREEN}Enabling necessary APIs for the Process Emails Cloud Function...${NC}"

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

# List of APIs to enable
APIS=(
    "cloudfunctions.googleapis.com"      # Cloud Functions API
    "cloudscheduler.googleapis.com"      # Cloud Scheduler API
    "secretmanager.googleapis.com"       # Secret Manager API
    "documentai.googleapis.com"          # Document AI API
    "gmail.googleapis.com"               # Gmail API
    "storage.googleapis.com"             # Cloud Storage API
    "sqladmin.googleapis.com"            # Cloud SQL Admin API
    "pubsub.googleapis.com"              # Pub/Sub API
    "cloudbuild.googleapis.com"          # Cloud Build API
    "artifactregistry.googleapis.com"    # Artifact Registry API
    "run.googleapis.com"                 # Cloud Run API (for Cloud Functions Gen 2)
    "vpcaccess.googleapis.com"           # VPC Access API (for connecting to Cloud SQL)
)

# Enable each API
for api in "${APIS[@]}"; do
    echo -e "\n${YELLOW}Enabling $api...${NC}"
    gcloud services enable $api --project=$PROJECT_ID
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error enabling $api. Please check your permissions and try again.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Successfully enabled $api.${NC}"
done

echo -e "\n${GREEN}All necessary APIs have been enabled successfully!${NC}"
echo "You can now proceed with setting up secrets and deploying the Cloud Function."
