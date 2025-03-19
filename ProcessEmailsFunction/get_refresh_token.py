import os
import pickle
import json
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request

# If modifying these scopes, delete the file token.pickle.
SCOPES = ['https://www.googleapis.com/auth/gmail.readonly', 'https://www.googleapis.com/auth/gmail.modify']

def main():
    creds = None
    # The file token.pickle stores the user's access and refresh tokens
    if os.path.exists('token.pickle'):
        with open('token.pickle', 'rb') as token:
            creds = pickle.load(token)
    
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            # Look for client_secret.json in the current directory
            client_secret_file = 'client_secret.json'
            
            # If not found, check if the user has the downloaded file in the Downloads folder
            if not os.path.exists(client_secret_file):
                downloads_path = os.path.expanduser('~/Downloads')
                for file in os.listdir(downloads_path):
                    if file.startswith('client_secret') and file.endswith('.json'):
                        client_secret_file = os.path.join(downloads_path, file)
                        print(f"Found client secret file: {client_secret_file}")
                        break
            
            flow = InstalledAppFlow.from_client_secrets_file(
                client_secret_file, SCOPES)
            creds = flow.run_local_server(port=0)
        
        # Save the credentials for the next run
        with open('token.pickle', 'wb') as token:
            pickle.dump(creds, token)
    
    print("\n=== OAuth Credentials ===")
    print(f"Access Token: {creds.token}")
    print(f"Refresh Token: {creds.refresh_token}")
    print(f"Token URI: {creds.token_uri}")
    print(f"Client ID: {creds.client_id}")
    print(f"Client Secret: {creds.client_secret}")
    
    # Create a JSON file with the OAuth credentials
    oauth_creds = {
        "refresh_token": creds.refresh_token,
        "client_id": creds.client_id,
        "client_secret": creds.client_secret,
        "token_uri": creds.token_uri
    }
    
    with open('oauth_credentials.json', 'w') as f:
        json.dump(oauth_creds, f, indent=2)
    
    print("\nOAuth credentials saved to oauth_credentials.json")
    print("You can now update the Secret Manager with these credentials:")
    print("gcloud secrets versions add gmail-docai-credentials --data-file=oauth_credentials.json --project=dispatch-dashboard-01")

if __name__ == '__main__':
    main()
