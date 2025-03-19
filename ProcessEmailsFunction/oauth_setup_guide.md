# OAuth Consent Screen Setup Guide

You need to configure the OAuth consent screen and add your email as a test user before you can use the OAuth client to access your Gmail account.

## Step 1: Navigate to OAuth Consent Screen

1. Go to the Google Cloud Console: https://console.cloud.google.com/
2. Make sure you're in the `dispatch-dashboard-01` project
3. In the left sidebar, click on "APIs & Services"
4. Click on "OAuth consent screen"

## Step 2: Configure the OAuth Consent Screen

If you haven't configured the consent screen yet:

1. Select "External" as the user type
2. Click "Create"
3. Fill in the required information:
   - App name: "Gmail Access App"
   - User support email: Your email address
   - Developer contact information: Your email address
4. Click "Save and Continue"

## Step 3: Add Scopes

1. Click "Add or Remove Scopes"
2. Search for "Gmail API" and select the following scopes:
   - `https://www.googleapis.com/auth/gmail.readonly`
   - `https://www.googleapis.com/auth/gmail.modify`
3. Click "Update"
4. Click "Save and Continue"

## Step 4: Add Test Users

1. Click "Add Users"
2. Enter your email address (the one you use for Gmail)
3. Click "Add"
4. Click "Save and Continue"

## Step 5: Review and Publish

1. Review your settings
2. Click "Back to Dashboard"

## Step 6: Run the Get Refresh Token Script Again

After completing the OAuth consent screen setup, run the get_refresh_token.py script again:

```
cd ProcessEmailsFunction
python get_refresh_token.py
```

This time, when you authorize the application, you should be able to proceed without the "not a developer" error.
