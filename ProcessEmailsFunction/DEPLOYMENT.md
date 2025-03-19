# Detailed Deployment Guide

This guide provides step-by-step instructions for deploying the Process Emails Cloud Function to Google Cloud.

## Prerequisites

Before you begin, make sure you have:

1. [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed and configured
2. [Python 3.9](https://www.python.org/downloads/) or later installed
3. Access to a Google Cloud project with billing enabled
4. Required APIs enabled in your Google Cloud project
5. Necessary Google Cloud resources created (Document AI processor, Cloud Storage bucket, Cloud SQL database)

## Step 1: Set Up Secret Manager Secrets

You need to create three secrets in Secret Manager:

### 1.1 Gmail API Credentials

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to "APIs & Services" > "Credentials"
3. Click "Create Credentials" > "Service Account"
4. Enter a name for the service account (e.g., "gmail-processor")
5. Click "Create and Continue"
6. Grant the service account the "Gmail API > Gmail API User" role
7. Click "Done"
8. Click on the newly created service account
9. Go to the "Keys" tab
10. Click "Add Key" > "Create new key"
11. Select "JSON" and click "Create"
12. Save the downloaded JSON file

Now create a Secret Manager secret with this JSON file:

```bash
gcloud secrets create gmail-docai-credentials \
    --data-file=/path/to/downloaded/credentials.json \
    --project=dispatch-dashboard-01
```

### 1.2 Document AI Credentials

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to "APIs & Services" > "Credentials"
3. Click "Create Credentials" > "Service Account"
4. Enter a name for the service account (e.g., "docai-processor")
5. Click "Create and Continue"
6. Grant the service account the "Document AI > Document AI User" role
7. Click "Done"
8. Click on the newly created service account
9. Go to the "Keys" tab
10. Click "Add Key" > "Create new key"
11. Select "JSON" and click "Create"
12. Save the downloaded JSON file

Now create a Secret Manager secret with this JSON file:

```bash
gcloud secrets create docai-credentials \
    --data-file=/path/to/downloaded/credentials.json \
    --project=dispatch-dashboard-01
```

### 1.3 Database Password

Create a Secret Manager secret with your database password:

```bash
echo -n "YOUR_DATABASE_PASSWORD" | gcloud secrets create db-password \
    --data-file=- \
    --project=dispatch-dashboard-01
```

## Step 2: Configure Gmail

### 2.1 Create the "OrderPDFs" Label

1. Go to [Gmail](https://mail.google.com/)
2. Click the gear icon in the top right and select "See all settings"
3. Go to the "Labels" tab
4. Scroll down to "Labels" section and click "Create new label"
5. Enter "OrderPDFs" as the label name
6. Click "Create"

### 2.2 Grant API Access to Gmail

You need to grant the service account access to your Gmail account:

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to "IAM & Admin" > "Service Accounts"
3. Find the gmail-processor service account
4. Copy the email address (it should look like `gmail-processor@dispatch-dashboard-01.iam.gserviceaccount.com`)
5. Go to [Gmail API Settings](https://console.cloud.google.com/apis/api/gmail.googleapis.com/overview)
6. Click "Enable" if the API is not already enabled
7. Go to [Gmail Delegation Settings](https://admin.google.com/ac/owl/domainwidedelegation)
8. Add a new API client:
   - Client ID: The numeric part of the service account email
   - OAuth Scopes: `https://www.googleapis.com/auth/gmail.readonly,https://www.googleapis.com/auth/gmail.modify`

## Step 3: Deploy the Cloud Function

### 3.1 Using Google Cloud Console

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to "Cloud Functions"
3. Click "CREATE FUNCTION"
4. Configure the function:
   - **Basics**:
     - Environment: 2nd gen
     - Function name: `process-gmail-orders`
     - Region: Select a region close to your users (e.g., `us-central1`)
   - **Trigger**:
     - Trigger type: Cloud Pub/Sub
     - Cloud Pub/Sub topic: Create a new topic (e.g., `process-emails-trigger`)
   - **Runtime, build, connections and security settings**:
     - Memory: 1 GiB (or more depending on your PDF sizes)
     - Timeout: 540 seconds (9 minutes)
     - Runtime service account: Select a service account with the necessary permissions
     - Connections: Connect to your Cloud SQL instance
     - Environment variables: Upload the `.env.yaml` file

5. Click "NEXT"
6. Configure the code:
   - Runtime: Python 3.9
   - Entry point: `process_gmail_orders`
   - Source code: Inline editor
   - Upload the `main.py` and `requirements.txt` files

7. Click "DEPLOY"

### 3.2 Using Command Line

#### On Linux/Mac:

```bash
chmod +x deploy.sh
./deploy.sh
```

#### On Windows (PowerShell):

```powershell
.\deploy.ps1
```

## Step 4: Set Up Cloud Scheduler

### 4.1 Using Google Cloud Console

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to "Cloud Scheduler"
3. Click "CREATE JOB"
4. Configure the job:
   - Name: `process-emails-job`
   - Region: Same as your Cloud Function
   - Frequency: Use cron syntax (e.g., `0 */6 * * *` for every 6 hours)
   - Timezone: Your local timezone
   - Target: Pub/Sub
   - Topic: The same topic you created for the Cloud Function
   - Message: `{"data": "trigger"}`

5. Click "CREATE"

### 4.2 Using Command Line

The deployment scripts already include creating the Cloud Scheduler job.

## Step 5: Test the Deployment

### 5.1 Manually Trigger the Function

```bash
gcloud scheduler jobs run process-emails-job \
    --project=dispatch-dashboard-01 \
    --location=us-central1
```

### 5.2 Check the Logs

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to "Cloud Functions"
3. Click on the `process-gmail-orders` function
4. Go to the "Logs" tab
5. Check for any errors or successful execution messages

## Troubleshooting

### Common Issues

1. **Missing Permissions**: Ensure the service accounts have the necessary permissions.
2. **API Not Enabled**: Make sure all required APIs are enabled in your project.
3. **Secret Manager Access**: Verify the function has access to Secret Manager secrets.
4. **Gmail Label Not Found**: Ensure the "OrderPDFs" label exists in your Gmail account.
5. **Database Connection Issues**: Check the database connection settings and make sure the Cloud SQL instance is running.

### Getting Help

If you encounter issues not covered in this guide:

1. Check the [Google Cloud Functions documentation](https://cloud.google.com/functions/docs)
2. Review the [Cloud Scheduler documentation](https://cloud.google.com/scheduler/docs)
3. Consult the [Document AI documentation](https://cloud.google.com/document-ai/docs)
4. Refer to the [Gmail API documentation](https://developers.google.com/gmail/api/guides)
