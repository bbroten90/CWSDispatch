import os
import json
import webbrowser

def main():
    # Check if client_secret.json exists
    if not os.path.exists('client_secret.json'):
        print("Error: client_secret.json not found in the current directory.")
        return
    
    # Load client secret file
    with open('client_secret.json', 'r') as f:
        client_info = json.load(f)
    
    # Extract project ID
    project_id = client_info.get('installed', {}).get('project_id')
    if not project_id:
        print("Error: Could not find project_id in client_secret.json")
        return
    
    # Print instructions
    print("\n=== OAuth Consent Screen Configuration ===")
    print(f"You need to add your email address as a test user in the OAuth consent screen.")
    print("\nPlease follow these steps:")
    print("1. Go to the Google Cloud Console OAuth consent screen")
    print("2. Add your email address as a test user")
    print("3. Save the changes")
    print("4. Run the get_refresh_token.py script again")
    
    # Generate URL to OAuth consent screen
    oauth_consent_url = f"https://console.cloud.google.com/apis/credentials/consent?project={project_id}"
    
    # Ask if user wants to open the URL
    print(f"\nWould you like to open the OAuth consent screen configuration? (y/n)")
    response = input().strip().lower()
    
    if response == 'y':
        print(f"Opening {oauth_consent_url} in your default browser...")
        webbrowser.open(oauth_consent_url)
    else:
        print(f"\nYou can manually navigate to: {oauth_consent_url}")
    
    print("\nAfter adding your email as a test user, run get_refresh_token.py again.")

if __name__ == '__main__':
    main()
