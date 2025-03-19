#!/bin/bash
# Script to deploy the Process Emails Cloud Function

# Configuration
PROJECT_ID="dispatch-dashboard-01"
REGION="us-central1"
FUNCTION_NAME="process-gmail-orders"
TOPIC_NAME="process-emails-trigger"
SERVICE_ACCOUNT="process-emails-sa@${PROJECT_ID}.iam.gserviceaccount.com"
RUNTIME="python39"
MEMORY="1024MB"
TIMEOUT="540s"
ENTRY_POINT="process_gmail_orders"
DB_INSTANCE="dispatch-dashboard-01:northamerica-northeast1:dispatch-db"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting deployment of ${FUNCTION_NAME}...${NC}"

# 1. Create Pub/Sub topic if it doesn't exist
echo "Creating Pub/Sub topic ${TOPIC_NAME}..."
gcloud pubsub topics create ${TOPIC_NAME} --project=${PROJECT_ID} || echo "Topic already exists"

# 2. Create service account if it doesn't exist
echo "Creating service account ${SERVICE_ACCOUNT}..."
gcloud iam service-accounts create process-emails-sa \
    --display-name="Process Emails Service Account" \
    --project=${PROJECT_ID} || echo "Service account already exists"

# 3. Grant necessary permissions to the service account
echo "Granting permissions to service account..."
# Secret Manager access
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/secretmanager.secretAccessor"

# Storage access
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/storage.objectAdmin"

# Document AI access
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/documentai.user"

# Cloud SQL access
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/cloudsql.client"

# 4. Deploy the Cloud Function
echo "Deploying Cloud Function..."
gcloud functions deploy ${FUNCTION_NAME} \
    --gen2 \
    --region=${REGION} \
    --runtime=${RUNTIME} \
    --service-account=${SERVICE_ACCOUNT} \
    --source=. \
    --entry-point=${ENTRY_POINT} \
    --trigger-topic=${TOPIC_NAME} \
    --memory=${MEMORY} \
    --timeout=${TIMEOUT} \
    --env-vars-file=.env.yaml \
    --project=${PROJECT_ID} \
    --set-secrets=DB_PASSWORD=db-password:latest \
    --vpc-connector=projects/${PROJECT_ID}/locations/${REGION}/connectors/cloud-sql-connector \
    --ingress-settings=internal-only

# Check if deployment was successful
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Cloud Function deployed successfully!${NC}"
else
    echo -e "${RED}Error deploying Cloud Function. Check the logs for details.${NC}"
    exit 1
fi

# 5. Create Cloud Scheduler job
echo "Creating Cloud Scheduler job..."
gcloud scheduler jobs create pubsub process-emails-job \
    --schedule="0 */6 * * *" \
    --topic=${TOPIC_NAME} \
    --message-body='{"data":"trigger"}' \
    --time-zone="America/Winnipeg" \
    --project=${PROJECT_ID} \
    --location=${REGION}

# Check if scheduler job creation was successful
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Cloud Scheduler job created successfully!${NC}"
else
    echo -e "${RED}Error creating Cloud Scheduler job. Check the logs for details.${NC}"
    exit 1
fi

echo -e "${GREEN}Deployment completed successfully!${NC}"
echo "You can now test the function by manually triggering the Cloud Scheduler job:"
echo "gcloud scheduler jobs run process-emails-job --project=${PROJECT_ID} --location=${REGION}"
