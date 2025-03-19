import base64
import os
import json
from google.oauth2 import service_account
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from google.cloud import documentai
from google.cloud import storage
from google.cloud import secretmanager
import psycopg2
import tempfile
import functions_framework
from datetime import datetime

# Cloud Function triggered by Cloud Scheduler
@functions_framework.cloud_event
def process_gmail_orders(cloud_event):
    """
    Cloud Function triggered by Cloud Scheduler to:
    1. Fetch emails with "OrderPDFs" label from Gmail
    2. Extract and save PDFs to Cloud Storage
    3. Process PDFs with Document AI
    4. Update SQL database with extracted information
    """
    # Set your project information
    project_id = os.environ.get('PROJECT_ID', 'dispatch-dashboard-01')
    location = os.environ.get('LOCATION', 'us-central1')
    processor_id = os.environ.get('PROCESSOR_ID', 'OrderReader')
    bucket_name = os.environ.get('BUCKET_NAME', 'cwsorders')
    
    # Cloud SQL connection info
    db_user = os.environ.get('DB_USER', 'dispatch-admin')
    db_password = os.environ.get('DB_PASSWORD')
    db_name = os.environ.get('DB_NAME', 'dispatch-dashboard')
    db_connection_name = os.environ.get('DB_CONNECTION_NAME', 'dispatch-dashboard-01:northamerica-northeast1:dispatch-db')
    
    print(f"Starting email processing job at {datetime.now().isoformat()}")
    
    # Get credentials from Secret Manager
    secret_client = secretmanager.SecretManagerServiceClient()
    
    # Get Gmail API credentials - first try to use the local file, then fall back to Secret Manager
    gmail_credentials_info = None
    try:
        # Try to use the local credentials file first
        gmail_credentials_path = os.path.join(os.path.dirname(__file__), 'gmail_credentials.json')
        if os.path.exists(gmail_credentials_path):
            print(f"Using local Gmail credentials file: {gmail_credentials_path}")
            with open(gmail_credentials_path, 'r') as f:
                gmail_credentials_info = json.load(f)
        else:
            # Fall back to Secret Manager
            gmail_secret_id = os.environ.get('GMAIL_SECRET_ID', 'gmail-docai-credentials')
            gmail_secret_name = f"projects/{project_id}/secrets/{gmail_secret_id}/versions/latest"
            gmail_response = secret_client.access_secret_version(name=gmail_secret_name)
            gmail_credentials_json = gmail_response.payload.data.decode("UTF-8")
            gmail_credentials_info = json.loads(gmail_credentials_json)
    except Exception as e:
        print(f"Error getting Gmail credentials: {str(e)}")
        return f"Error getting Gmail credentials: {str(e)}"
    
    # Get Document AI credentials
    docai_credentials_json = None
    try:
        docai_secret_id = os.environ.get('DOCAI_SECRET_ID', 'docai-credentials')
        docai_secret_name = f"projects/{project_id}/secrets/{docai_secret_id}/versions/latest"
        docai_response = secret_client.access_secret_version(name=docai_secret_name)
        docai_credentials_json = docai_response.payload.data.decode("UTF-8")
    except Exception as e:
        print(f"Error getting Document AI credentials: {str(e)}")
        return f"Error getting Document AI credentials: {str(e)}"
    
    # Get DB password if not in environment
    if not db_password:
        try:
            db_secret_id = os.environ.get('DB_SECRET_ID', 'db-password')
            db_secret_name = f"projects/{project_id}/secrets/{db_secret_id}/versions/latest"
            db_response = secret_client.access_secret_version(name=db_secret_name)
            db_password = db_response.payload.data.decode("UTF-8")
        except Exception as e:
            print(f"Error getting DB password: {str(e)}")
            return f"Error getting DB password: {str(e)}"
    
    # Initialize Gmail API
    try:
        SCOPES = ['https://www.googleapis.com/auth/gmail.readonly', 'https://www.googleapis.com/auth/gmail.modify']
        # Use OAuth credentials instead of service account
        gmail_credentials = Credentials.from_authorized_user_info(
            gmail_credentials_info, scopes=SCOPES)
        
        # No need for with_subject() with OAuth credentials
        
        gmail_service = build('gmail', 'v1', credentials=gmail_credentials)
    except Exception as e:
        print(f"Error initializing Gmail API: {str(e)}")
        return f"Error initializing Gmail API: {str(e)}"

    # Get label ID for "OrderPDFs"
    try:
        labels_response = gmail_service.users().labels().list(userId='me').execute()
        order_pdfs_label_id = None
        for label in labels_response.get('labels', []):
            if label['name'] == 'OrderPDFs':
                order_pdfs_label_id = label['id']
                break
        
        if not order_pdfs_label_id:
            print("Error: 'OrderPDFs' label not found in Gmail")
            return "Error: 'OrderPDFs' label not found in Gmail"
    except Exception as e:
        print(f"Error getting Gmail labels: {str(e)}")
        return f"Error getting Gmail labels: {str(e)}"

    # Get all emails with the "OrderPDFs" label
    try:
        results = gmail_service.users().messages().list(
            userId='me', 
            labelIds=[order_pdfs_label_id],
            q='has:attachment'
        ).execute()

        messages = results.get('messages', [])
        
        if not messages:
            print('No new order emails found.')
            return 'No new order emails found.'
    except Exception as e:
        print(f"Error getting emails: {str(e)}")
        return f"Error getting emails: {str(e)}"

    # Initialize Document AI client
    try:
        docai_credentials = service_account.Credentials.from_service_account_info(
            json.loads(docai_credentials_json))
        docai_client = documentai.DocumentProcessorServiceClient(credentials=docai_credentials)
        processor_name = docai_client.processor_path(project_id, location, processor_id)
    except Exception as e:
        print(f"Error initializing Document AI client: {str(e)}")
        return f"Error initializing Document AI client: {str(e)}"

    # Initialize Storage client
    try:
        storage_client = storage.Client(credentials=docai_credentials)
        bucket = storage_client.bucket(bucket_name)
    except Exception as e:
        print(f"Error initializing Storage client: {str(e)}")
        return f"Error initializing Storage client: {str(e)}"
    
    # Database connection function
    def get_db_connection():
        """Create and return a new database connection."""
        try:
            # For local testing, use the TCP connection
            if os.environ.get('LOCAL_DEVELOPMENT'):
                print("Using local development connection")
                connection = psycopg2.connect(
                    host=os.environ.get('DB_HOST', '35.203.126.72'),  # Use Cloud SQL Proxy for local testing
                    port=os.environ.get('DB_PORT', '5432'),
                    user=db_user,
                    password=db_password,
                    dbname=db_name
                )
            else:
                # For production in Cloud Functions
                print("Using Cloud SQL socket connection")
                socket_dir = os.environ.get("DB_SOCKET_DIR", "/cloudsql")
                connection = psycopg2.connect(
                    host=f'{socket_dir}/{db_connection_name}',
                    user=db_user,
                    password=db_password,
                    dbname=db_name
                )
            return connection
        except Exception as e:
            print(f"Error connecting to database: {str(e)}")
            raise e

    processed_count = 0
    for message in messages:
        try:
            # Get the message details
            msg = gmail_service.users().messages().get(
                userId='me', id=message['id']).execute()
            
            # Get email metadata
            email_date = int(msg['internalDate']) // 1000  # Convert to seconds
            email_subject = next((header['value'] for header in msg['payload']['headers'] 
                                if header['name'].lower() == 'subject'), 'No Subject')
            
            print(f"Processing email: {email_subject} from {datetime.fromtimestamp(email_date).isoformat()}")
            
            # Helper function to recursively find all attachments in the message structure
            def find_attachments(message_part, depth=0):
                """Recursively find all attachments in the message structure."""
                attachments = []
                indent = "  " * depth
                
                # Debug: Print message part structure
                print(f"{indent}Checking part: mimeType={message_part.get('mimeType')}, filename={message_part.get('filename')}")
                if 'body' in message_part:
                    print(f"{indent}Body: size={message_part['body'].get('size')}, attachmentId={message_part['body'].get('attachmentId')}")
                
                # Check if this part has an attachment ID (which means it's an attachment)
                if 'body' in message_part and 'attachmentId' in message_part['body']:
                    print(f"{indent}Found attachment: {message_part.get('filename', 'unnamed_attachment')}")
                    attachments.append(message_part)
                
                # Check if this part has sub-parts
                if 'parts' in message_part:
                    print(f"{indent}Part has {len(message_part['parts'])} sub-parts")
                    for part in message_part['parts']:
                        # Recursively check any nested parts
                        attachments.extend(find_attachments(part, depth + 1))
                
                # Check for mimeType 'message/rfc822' which indicates a forwarded email
                if message_part.get('mimeType') == 'message/rfc822':
                    print(f"{indent}Found forwarded email")
                    if 'parts' in message_part:
                        for part in message_part['parts']:
                            attachments.extend(find_attachments(part, depth + 1))
                
                return attachments
            
            # Get all attachments recursively (handles forwarded emails)
            print(f"Searching for attachments in email: {email_subject}")
            attachments = find_attachments(msg['payload'])
            
            if not attachments:
                print(f"No PDF attachments found in email: {email_subject}")
                # Debug: Print the full message structure to help diagnose the issue
                print(f"Message structure: {json.dumps(msg['payload'], indent=2)[:500]}...")  # Truncate for readability
                continue
            
            for part in attachments:
                attachment_id = part['body'].get('attachmentId')
                if not attachment_id:
                    print(f"No attachment ID found for {part.get('filename')}")
                    continue
                
                attachment = gmail_service.users().messages().attachments().get(
                    userId='me', messageId=message['id'], id=attachment_id
                ).execute()
                
                file_data = base64.urlsafe_b64decode(attachment['data'])
                
                # Save PDF to temporary file
                with tempfile.NamedTemporaryFile(suffix='.pdf', delete=False) as temp_pdf:
                    temp_pdf.write(file_data)
                    temp_path = temp_pdf.name
                    
                    # Upload PDF to Cloud Storage
                    blob_name = f"orders/{email_date}_{email_subject}_{part['filename']}"
                    blob = bucket.blob(blob_name)
                    blob.upload_from_filename(temp_path)
                    
                    # Process with Document AI
                    with open(temp_path, "rb") as pdf_file:
                        pdf_content = pdf_file.read()
                    
                    # Use Document AI to process the PDF
                    document = {"content": pdf_content, "mime_type": "application/pdf"}
                    request = {"name": processor_name, "raw_document": document}
                    result = docai_client.process_document(request=request)
                    document = result.document
                    
                    # Extract the required fields based on your Document AI processor configuration
                    order_data = {}
                    for entity in document.entities:
                        order_data[entity.type_] = entity.mention_text
                    
                    # Now update your SQL database with both header and line item data
                    # Create a new connection for each message
                    conn = None
                    cursor = None
                    try:
                        conn = get_db_connection()
                        cursor = conn.cursor()
                        
                        # Start a transaction
                        # Map Document AI fields to database fields
                        # This mapping will depend on how your Document AI processor is configured
                        # and what fields it extracts
                        
                        # 1. Insert Order Header information
                        # Using the actual schema from database-schema.sql
                        header_query = """
                        INSERT INTO order_headers 
                        (document_id, manufacturer_id, order_date, po_number, 
                        requested_shipment_date, requested_delivery_date, customer_id, 
                        special_requirements, status, total_quantity, total_weight_kg, 
                        total_volume_cubic_m, estimated_revenue)
                        VALUES 
                        (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                        RETURNING order_id
                        """
                        
                        # Look up or create manufacturer
                        manufacturer_id = None
                        if 'manufacturer_id' in order_data:
                            # Look up manufacturer by name
                            mfg_query = "SELECT manufacturer_id FROM manufacturers WHERE name = %s"
                            cursor.execute(mfg_query, (order_data.get('manufacturer_id'),))
                            mfg_result = cursor.fetchone()
                            if mfg_result:
                                manufacturer_id = mfg_result[0]
                            else:
                                # Create new manufacturer
                                print(f"Creating new manufacturer: {order_data.get('manufacturer_id')}")
                                insert_mfg_query = "INSERT INTO manufacturers (name) VALUES (%s) RETURNING manufacturer_id"
                                cursor.execute(insert_mfg_query, (order_data.get('manufacturer_id'),))
                                manufacturer_id = cursor.fetchone()[0]
                        
                        # Look up customer - do not create if not found
                        customer_id = None
                        if 'customer_id' in order_data:
                            # Look up customer by ID
                            cust_query = "SELECT customer_id FROM customers WHERE customer_id = %s"
                            cursor.execute(cust_query, (order_data.get('customer_id'),))
                            cust_result = cursor.fetchone()
                            if cust_result:
                                customer_id = cust_result[0]
                            else:
                                # Log warning instead of creating an incomplete customer
                                print(f"Warning: Customer {order_data.get('customer_id')} not found in database. Please import customer data first.")
                                # Skip this order if customer is required
                                if os.environ.get('REQUIRE_CUSTOMER', 'false').lower() == 'true':
                                    print(f"Skipping order because customer {order_data.get('customer_id')} not found and REQUIRE_CUSTOMER=true")
                                    raise ValueError(f"Customer {order_data.get('customer_id')} not found in database")
                        
                        # Convert string values to appropriate types
                        try:
                            total_quantity = int(order_data.get('total_quantity', 0))
                        except (ValueError, TypeError):
                            total_quantity = 0
                            
                        try:
                            total_weight_kg = float(order_data.get('total_weight_kg', 0))
                        except (ValueError, TypeError):
                            total_weight_kg = 0.0
                            
                        try:
                            total_volume_cubic_m = float(order_data.get('total_volume_cubic_m', 0))
                        except (ValueError, TypeError):
                            total_volume_cubic_m = 0.0
                            
                        try:
                            estimated_revenue = float(order_data.get('estimated_revenue', 0))
                        except (ValueError, TypeError):
                            estimated_revenue = 0.0
                        
                        # Parse dates
                        order_date = order_data.get('order_date', datetime.fromtimestamp(email_date).strftime('%Y-%m-%d'))
                        requested_shipment_date = order_data.get('requested_shipment_date', None)
                        requested_delivery_date = order_data.get('requested_delivery_date', None)
                        
                        header_values = (
                            order_data.get('document_id', f"PO-{email_date}"),  # document_id
                            manufacturer_id,  # manufacturer_id
                            order_date,  # order_date
                            order_data.get('po_number', ''),  # po_number
                            requested_shipment_date,  # requested_shipment_date
                            requested_delivery_date,  # requested_delivery_date
                            customer_id,  # customer_id
                            order_data.get('special_requirements', ''),  # special_requirements
                            'RECEIVED',  # status
                            total_quantity,  # total_quantity
                            total_weight_kg,  # total_weight_kg
                            total_volume_cubic_m,  # total_volume_cubic_m
                            estimated_revenue  # estimated_revenue
                        )
                        
                        cursor.execute(header_query, header_values)
                        order_id = cursor.fetchone()[0]
                        
                        # 2. Insert Order Line Items
                        # This assumes your Document AI processor extracts line items as an array/list
                        line_items = []
                        
                        # Look for entities that might be line items
                        # Adjust this logic based on your Document AI processor's output
                        current_item = {}
                        
                        for entity in document.entities:
                            # Example pattern detection for line items
                            if entity.type_.startswith('line_item.'):
                                # Extract the property name after the dot
                                prop = entity.type_.split('.')[1]
                                
                                # If we find an item_number and we already have a current_item, save it and start a new one
                                if prop == 'item_number' and current_item:
                                    line_items.append(current_item)
                                    current_item = {}
                                
                                # Add this property to the current item
                                current_item[prop] = entity.mention_text
                        
                        # Don't forget to add the last item if it exists
                        if current_item:
                            line_items.append(current_item)
                        
                        # Insert each line item
                        # Using the actual schema from database-schema.sql
                        line_item_query = """
                        INSERT INTO order_line_items
                        (order_id, product_id, quantity, weight_kg, volume_cubic_m)
                        VALUES
                        (%s, %s, %s, %s, %s)
                        """
                        
                        for item in line_items:
                            # Convert string values to appropriate types
                            try:
                                quantity = int(item.get('quantity', 0))
                            except (ValueError, TypeError):
                                quantity = 0
                                
                            try:
                                weight_kg = float(item.get('weight_kg', 0))
                            except (ValueError, TypeError):
                                weight_kg = 0.0
                                
                            try:
                                volume_cubic_m = float(item.get('volume_cubic_m', 0))
                            except (ValueError, TypeError):
                                volume_cubic_m = 0.0
                            
                            line_item_values = (
                                order_id,  # order_id
                                item.get('product_id', 'UNKNOWN'),  # product_id
                                quantity,  # quantity
                                weight_kg,  # weight_kg
                                volume_cubic_m  # volume_cubic_m
                            )
                            cursor.execute(line_item_query, line_item_values)
                        
                        # Commit the transaction
                        conn.commit()
                        print(f"Processed order: {order_data.get('document_id', f'PO-{email_date}')} with {len(line_items)} line items")
                    except Exception as db_error:
                        # Rollback the transaction in case of error
                        if conn:
                            try:
                                conn.rollback()
                            except Exception:
                                pass  # Ignore errors during rollback
                        print(f"Database error processing order: {str(db_error)}")
                        raise db_error  # Re-raise to be caught by the outer try/except
                    finally:
                        # Always close cursor and connection
                        if cursor:
                            cursor.close()
                        if conn:
                            conn.close()
                    
                    print(f"Processed order: {order_data.get('document_id', f'PO-{email_date}')} with {len(line_items)} line items")
                    
                    # Delete temporary file
                    os.unlink(temp_path)
                    
                    # Mark the email as processed
                    gmail_service.users().messages().modify(
                        userId='me',
                        id=message['id'],
                        body={'removeLabelIds': ['UNREAD', order_pdfs_label_id], 'addLabelIds': ['PROCESSED']}
                    ).execute()
                    
                    processed_count += 1
        except Exception as e:
            print(f"Error processing message {message['id']}: {str(e)}")
            # Continue with next message instead of failing the entire function
            continue
    
    result_message = f"Processed {processed_count} order emails"
    print(result_message)
    return result_message
