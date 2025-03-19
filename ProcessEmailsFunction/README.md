# Process Emails Cloud Function

This Cloud Function automatically processes emails with PDF attachments from Gmail, extracts data using Document AI, and stores the information in a Cloud SQL database.

## Project Structure

- `main.py` - The main Cloud Function code
- `requirements.txt` - Python dependencies
- `.env.yaml` - Environment variables for deployment
- `deploy.sh` - Bash script for deploying to Google Cloud (Linux/Mac)
- `deploy.ps1` - PowerShell script for deploying to Google Cloud (Windows)
- `test_locally.py` - Script for testing the function locally
- `test.sh` - Bash script for running local tests (Linux/Mac)
- `test.bat` - Batch script for running local tests (Windows)
- `setup_secrets.sh` - Bash script for setting up Secret Manager secrets (Linux/Mac)
- `setup_secrets.ps1` - PowerShell script for setting up Secret Manager secrets (Windows)
- `enable_apis.sh` - Bash script for enabling necessary Google Cloud APIs (Linux/Mac)
- `enable_apis.ps1` - PowerShell script for enabling necessary Google Cloud APIs (Windows)
- `make_executable.sh` - Bash script to make all shell scripts executable (Linux/Mac)
- `create_deployment_zip.ps1` - PowerShell script to create a deployment ZIP file (Windows)
- `DEPLOYMENT.md` - Detailed deployment guide for command-line deployment
- `MANUAL_DEPLOYMENT.md` - Detailed guide for manual deployment using Google Cloud Console
- `.gitignore` - Git ignore file

## Prerequisites

Before deploying this function, ensure you have:

1. A Google Cloud project with billing enabled
2. The following APIs enabled:
   - Cloud Functions API
   - Cloud Scheduler API
   - Secret Manager API
   - Document AI API
   - Gmail API
   - Cloud Storage API
   - Cloud SQL Admin API

3. A Document AI processor set up for extracting order information from PDFs
4. A Cloud Storage bucket for storing the PDFs
5. A Cloud SQL PostgreSQL database with the required schema
6. A Gmail account with a label called "OrderPDFs" for identifying emails to process

## Setup Instructions

### 1. Make Scripts Executable (Linux/Mac only)

On Linux/Mac systems, you need to make the shell scripts executable first:

```bash
chmod +x make_executable.sh
./make_executable.sh
```

This will make all the shell scripts in the project executable.

### 2. Enable Required APIs

You can enable the necessary Google Cloud APIs using the provided scripts:

**On Linux/Mac:**
```bash
./enable_apis.sh
```

**On Windows (PowerShell):**
```powershell
.\enable_apis.ps1
```

### 3. Set up Secret Manager Secrets

You need to create three secrets in Secret Manager. You can do this manually or use the provided scripts:

**On Linux/Mac:**
```bash
./setup_secrets.sh
```

**On Windows (PowerShell):**
```powershell
.\setup_secrets.ps1
```

The scripts will guide you through creating the following secrets:

1. **Gmail API Credentials**:
   - Secret Manager secret named `gmail-docai-credentials` with your Gmail API credentials JSON

2. **Document AI Credentials**:
   - Secret Manager secret named `docai-credentials` with your Document AI credentials JSON

3. **Database Password**:
   - Secret Manager secret named `db-password` with your database password

### 4. Deploy the Cloud Function

#### Using Google Cloud Console (Recommended for Windows):

1. Create a deployment ZIP file:
   ```powershell
   .\create_deployment_zip.ps1
   ```

2. Follow the detailed instructions in the [manual deployment guide](./MANUAL_DEPLOYMENT.md) to deploy the ZIP file using the Google Cloud Console.

#### Using Command Line (Requires Google Cloud SDK):

**On Linux/Mac:**
```bash
./deploy.sh
```

**On Windows (PowerShell):**
```powershell
.\deploy.ps1
```

For detailed command-line deployment instructions, see the [deployment guide](./DEPLOYMENT.md).

### 5. Testing Locally

Before deploying, you can test the function locally:

**On Linux/Mac:**
```bash
./test.sh
```

**On Windows:**
```
test.bat
```

## Troubleshooting

If you encounter issues:

1. Check the Cloud Function logs for error messages
2. Verify that all secrets are correctly set up in Secret Manager
3. Ensure the service account has the necessary permissions
4. Check that the Gmail label exists and is correctly configured
5. Verify the Document AI processor is working correctly

## Security Considerations

- All credentials are stored in Secret Manager for security
- The function uses environment variables to avoid hardcoded secrets
- Database connections use the Cloud SQL Auth Proxy for secure access

## Domain-Wide Delegation for Gmail API

If you're using a service account to access Gmail, you need to set up domain-wide delegation:

1. For Google Workspace accounts:
   - Go to the Google Workspace Admin Console
   - Navigate to Security > API Controls > Domain-wide Delegation
   - Add the service account client ID and the required scopes:
     - `https://www.googleapis.com/auth/gmail.readonly`
     - `https://www.googleapis.com/auth/gmail.modify`

2. For personal Gmail accounts:
   - The service account needs to be configured with the subject (email address) of the Gmail account
   - This is already set up in the `main.py` file with the line:
     ```python
     gmail_credentials = gmail_credentials.with_subject('cwsorders0@gmail.com')
     ```
   - Make sure to update this email address if you're using a different Gmail account
