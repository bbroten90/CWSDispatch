# PowerShell script to set up the necessary secrets in Secret Manager

# Configuration
$PROJECT_ID = "dispatch-dashboard-01"

Write-Host "Setting up Secret Manager secrets for the Process Emails Cloud Function..." -ForegroundColor Green

# Check if gcloud is installed
try {
    $gcloudVersion = gcloud --version
} catch {
    Write-Host "Error: gcloud CLI is not installed. Please install it first." -ForegroundColor Red
    Write-Host "Visit https://cloud.google.com/sdk/docs/install for installation instructions."
    exit 1
}

# Check if the user is logged in
$activeAccount = gcloud auth list --filter=status:ACTIVE --format="value(account)"
if (-not $activeAccount) {
    Write-Host "Error: You are not logged in to gcloud. Please run 'gcloud auth login' first." -ForegroundColor Red
    exit 1
}

# Check if the project exists
try {
    $projectInfo = gcloud projects describe $PROJECT_ID
} catch {
    Write-Host "Error: Project $PROJECT_ID does not exist or you don't have access to it." -ForegroundColor Red
    exit 1
}

# Enable Secret Manager API
Write-Host "Enabling Secret Manager API..."
gcloud services enable secretmanager.googleapis.com --project=$PROJECT_ID

# 1. Set up Gmail API credentials secret
Write-Host "`nSetting up Gmail API credentials secret..." -ForegroundColor Yellow
$GMAIL_CREDS_PATH = Read-Host "Please provide the path to your Gmail API credentials JSON file"

if (-not (Test-Path $GMAIL_CREDS_PATH)) {
    Write-Host "Error: File not found at $GMAIL_CREDS_PATH" -ForegroundColor Red
    exit 1
}

Write-Host "Creating gmail-docai-credentials secret..."
try {
    gcloud secrets create gmail-docai-credentials `
        --data-file="$GMAIL_CREDS_PATH" `
        --project=$PROJECT_ID
} catch {
    Write-Host "Error creating gmail-docai-credentials secret." -ForegroundColor Red
    exit 1
}

# 2. Set up Document AI credentials secret
Write-Host "`nSetting up Document AI credentials secret..." -ForegroundColor Yellow
$DOCAI_CREDS_PATH = Read-Host "Please provide the path to your Document AI credentials JSON file"

if (-not (Test-Path $DOCAI_CREDS_PATH)) {
    Write-Host "Error: File not found at $DOCAI_CREDS_PATH" -ForegroundColor Red
    exit 1
}

Write-Host "Creating docai-credentials secret..."
try {
    gcloud secrets create docai-credentials `
        --data-file="$DOCAI_CREDS_PATH" `
        --project=$PROJECT_ID
} catch {
    Write-Host "Error creating docai-credentials secret." -ForegroundColor Red
    exit 1
}

# 3. Set up database password secret
Write-Host "`nSetting up database password secret..." -ForegroundColor Yellow
$securePassword = Read-Host "Please enter your database password" -AsSecureString
$DB_PASSWORD = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword))

Write-Host "Creating db-password secret..."
try {
    $DB_PASSWORD | gcloud secrets create db-password `
        --data-file=- `
        --project=$PROJECT_ID
} catch {
    Write-Host "Error creating db-password secret." -ForegroundColor Red
    exit 1
}

Write-Host "`nAll secrets have been created successfully!" -ForegroundColor Green
Write-Host "You can now proceed with deploying the Cloud Function."
