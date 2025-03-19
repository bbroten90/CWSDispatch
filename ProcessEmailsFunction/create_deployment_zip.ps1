# PowerShell script to create a deployment ZIP file for the Process Emails Cloud Function

# Configuration
$OUTPUT_ZIP = "process_emails_function.zip"

Write-Host "Creating deployment ZIP file for the Process Emails Cloud Function..." -ForegroundColor Green

# Check if gmail_credentials.json exists
if (-not (Test-Path "gmail_credentials.json")) {
    Write-Host "Warning: gmail_credentials.json not found. Copying from Downloads folder..." -ForegroundColor Yellow
    
    # Try to find credentials.json in Downloads folder
    $DOWNLOADS_PATH = [Environment]::GetFolderPath("UserProfile") + "\Downloads"
    $CREDENTIALS_FILE = $DOWNLOADS_PATH + "\credentials.json"
    
    if (Test-Path $CREDENTIALS_FILE) {
        Copy-Item $CREDENTIALS_FILE -Destination "gmail_credentials.json"
        Write-Host "Copied credentials.json from Downloads folder to gmail_credentials.json" -ForegroundColor Green
    } else {
        Write-Host "Error: credentials.json not found in Downloads folder. Please provide the Gmail API credentials file." -ForegroundColor Red
        exit 1
    }
}

# Create a temporary directory for the deployment files
$TEMP_DIR = "temp_deploy"
if (Test-Path $TEMP_DIR) {
    Remove-Item -Recurse -Force $TEMP_DIR
}
New-Item -ItemType Directory -Path $TEMP_DIR | Out-Null

# Copy the necessary files to the temporary directory
Copy-Item "main.py" -Destination $TEMP_DIR
Copy-Item "requirements.txt" -Destination $TEMP_DIR
Copy-Item "gmail_credentials.json" -Destination $TEMP_DIR

# Create the ZIP file
if (Test-Path $OUTPUT_ZIP) {
    Remove-Item -Force $OUTPUT_ZIP
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($TEMP_DIR, $OUTPUT_ZIP)

# Clean up the temporary directory
Remove-Item -Recurse -Force $TEMP_DIR

Write-Host "Deployment ZIP file created: $OUTPUT_ZIP" -ForegroundColor Green
Write-Host "You can now deploy this ZIP file to Google Cloud Functions using the Google Cloud Console." -ForegroundColor Green
Write-Host "Follow the instructions in MANUAL_DEPLOYMENT.md for detailed steps." -ForegroundColor Green
