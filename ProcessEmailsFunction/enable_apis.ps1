# PowerShell script to enable the necessary APIs in Google Cloud

# Configuration
$PROJECT_ID = "dispatch-dashboard-01"

Write-Host "Enabling necessary APIs for the Process Emails Cloud Function..." -ForegroundColor Green

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

# List of APIs to enable
$APIS = @(
    "cloudfunctions.googleapis.com",      # Cloud Functions API
    "cloudscheduler.googleapis.com",      # Cloud Scheduler API
    "secretmanager.googleapis.com",       # Secret Manager API
    "documentai.googleapis.com",          # Document AI API
    "gmail.googleapis.com",               # Gmail API
    "storage.googleapis.com",             # Cloud Storage API
    "sqladmin.googleapis.com",            # Cloud SQL Admin API
    "pubsub.googleapis.com",              # Pub/Sub API
    "cloudbuild.googleapis.com",          # Cloud Build API
    "artifactregistry.googleapis.com",    # Artifact Registry API
    "run.googleapis.com",                 # Cloud Run API (for Cloud Functions Gen 2)
    "vpcaccess.googleapis.com"            # VPC Access API (for connecting to Cloud SQL)
)

# Enable each API
foreach ($api in $APIS) {
    Write-Host "`nEnabling $api..." -ForegroundColor Yellow
    try {
        gcloud services enable $api --project=$PROJECT_ID
        Write-Host "Successfully enabled $api." -ForegroundColor Green
    } catch {
        Write-Host "Error enabling $api. Please check your permissions and try again." -ForegroundColor Red
        exit 1
    }
}

Write-Host "`nAll necessary APIs have been enabled successfully!" -ForegroundColor Green
Write-Host "You can now proceed with setting up secrets and deploying the Cloud Function."
