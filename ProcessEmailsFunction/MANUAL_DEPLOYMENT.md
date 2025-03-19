# Manual Deployment Guide for Process Emails Cloud Function

Since you might not have the Google Cloud SDK (gcloud CLI) installed, here's a guide to deploy the Cloud Function manually using the Google Cloud Console.

## Prerequisites

1. Make sure you have a Google Cloud account and access to the `dispatch-dashboard-01` project
2. Ensure you have the necessary permissions to create and deploy Cloud Functions

## Step 1: Prepare the Deployment Package

1. Create a ZIP file containing the following files:
   - `main.py` - The main Cloud Function code
   - `requirements.txt` - Python dependencies
   - `gmail_credentials.json` - The service account key file for Gmail API access

## Step 2: Deploy the Cloud Function

1. Go to the Google Cloud Console: https://console.cloud.google.com/
2. Make sure you're in the `dispatch-dashboard-01` project
3. Navigate to "Cloud Functions" in the left sidebar
4. Click "CREATE FUNCTION"
5. Configure the function:
   - **Environment**: 2nd gen
   - **Function name**: `process-gmail-orders`
   - **Region**: `us-central1`
   - **Runtime**: Python 3.9
   - **Memory**: 1024 MB
   - **Timeout**: 540 seconds
   - **Service account**: `process-emails-sa@dispatch-dashboard-01.iam.gserviceaccount.com`
6. Click "NEXT"
7. For the trigger:
   - **Trigger type**: Cloud Pub/Sub
   - **Cloud Pub/Sub topic**: `process-emails-trigger` (create it if it doesn't exist)
8. Click "NEXT"
9. For the code:
   - **Source code**: ZIP upload
   - **Runtime**: Python 3.9
   - **Entry point**: `process_gmail_orders`
   - Upload the ZIP file you created in Step 1
10. For the runtime environment variables:
    - Add the following environment variables:
      - `PROJECT_ID`: `dispatch-dashboard-01`
      - `LOCATION`: `us-central1`
      - `PROCESSOR_ID`: `OrderReader`
      - `BUCKET_NAME`: `cwsorders`
      - `DB_USER`: `dispatch-admin`
      - `DB_NAME`: `dispatch-dashboard`
      - `DB_CONNECTION_NAME`: `dispatch-dashboard-01:northamerica-northeast1:dispatch-db`
11. For the secrets:
    - Add the following secret:
      - `DB_PASSWORD`: `db-password:latest`
12. For the connections:
    - VPC connector: `projects/dispatch-dashboard-01/locations/us-central1/connectors/cloud-sql-connector`
    - Ingress settings: Internal only
13. Click "DEPLOY"

## Step 3: Create a Cloud Scheduler Job

1. Go to the Google Cloud Console: https://console.cloud.google.com/
2. Navigate to "Cloud Scheduler" in the left sidebar
3. Click "CREATE JOB"
4. Configure the job:
   - **Name**: `process-emails-job`
   - **Region**: `us-central1`
   - **Frequency**: `*/15 5-20 * * *` (every 15 minutes from 5:00 AM to 8:45 PM)
   - **Timezone**: America/Chicago
   - **Target type**: Pub/Sub
   - **Topic**: `process-emails-trigger`
   - **Message body**: `{"data":"trigger"}`
5. Click "CREATE"

## Step 4: Test the Cloud Function

1. Go to the Google Cloud Console: https://console.cloud.google.com/
2. Navigate to "Cloud Scheduler" in the left sidebar
3. Find the `process-emails-job` job
4. Click "RUN NOW" to manually trigger the job
5. Check the Cloud Function logs to see if it's working correctly

## Troubleshooting

If you encounter any issues:

1. Check the Cloud Function logs for error messages
2. Verify that the service account has the necessary permissions:
   - Secret Manager Secret Accessor
   - Storage Object Admin
   - Document AI User
   - Cloud SQL Client
3. Make sure the Gmail account has the "OrderPDFs" label
4. Verify that the Document AI processor is set up correctly
