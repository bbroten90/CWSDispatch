#!/usr/bin/env python3
"""
CSV to SQL Import Script

This script imports data from CSV files into the SQL database:
- CustomerList.csv -> customers table
- HazardList.csv -> hazards table
- All-Products-WithValues.csv -> products table

Usage:
    python import_csv_to_sql.py

Environment variables:
    DB_HOST: Database host
    DB_PORT: Database port
    DB_NAME: Database name
    DB_USER: Database user
    DB_PASSWORD: Database password (or will be retrieved from Secret Manager using DB_SECRET_ID)
    DB_SECRET_ID: Secret ID for retrieving DB_PASSWORD from Secret Manager
    PROJECT_ID: Google Cloud project ID
"""

import pandas as pd
import psycopg2
import os
import sys
import yaml
import json
from google.cloud import secretmanager

# Load environment variables from .env.yaml if it exists
if os.path.exists('.env.yaml'):
    try:
        with open('.env.yaml', 'r') as f:
            env_vars = yaml.safe_load(f)
            for key, value in env_vars.items():
                os.environ[key] = str(value)
        print("Loaded environment variables from .env.yaml")
    except Exception as e:
        print(f"Error loading .env.yaml: {e}")

def get_db_connection():
    """Create and return a database connection."""
    try:
        # Get database connection parameters from environment variables
        db_host = os.environ.get('DB_HOST', '35.203.126.72')
        db_port = os.environ.get('DB_PORT', '5432')
        db_name = os.environ.get('DB_NAME', 'dispatch-dashboard')
        db_user = os.environ.get('DB_USER', 'dispatch-admin')
        db_password = os.environ.get('DB_PASSWORD')
        
        # If DB_PASSWORD is not set, try to get it from Secret Manager
        if not db_password:
            print("DB_PASSWORD not found in environment variables, trying to get it from Secret Manager...")
            try:
                project_id = os.environ.get('PROJECT_ID', 'dispatch-dashboard-01')
                db_secret_id = os.environ.get('DB_SECRET_ID', 'db-password')
                
                # Create the Secret Manager client
                secret_client = secretmanager.SecretManagerServiceClient()
                
                # Build the resource name of the secret version
                db_secret_name = f"projects/{project_id}/secrets/{db_secret_id}/versions/latest"
                
                # Access the secret version
                db_response = secret_client.access_secret_version(name=db_secret_name)
                
                # Extract the secret
                db_password = db_response.payload.data.decode("UTF-8")
                print("Successfully retrieved DB_PASSWORD from Secret Manager")
            except Exception as secret_error:
                print(f"Error getting DB password from Secret Manager: {str(secret_error)}")
                raise ValueError("DB_PASSWORD environment variable is required or Secret Manager access failed")
        
        # Connect to the database
        print(f"Connecting to database {db_name} on {db_host}:{db_port} as {db_user}")
        connection = psycopg2.connect(
            host=db_host,
            port=db_port,
            user=db_user,
            password=db_password,
            dbname=db_name
        )
        print("Successfully connected to the database")
        return connection
    except Exception as e:
        print(f"Error connecting to database: {str(e)}")
        raise e

def import_customers(cursor, conn):
    """Import CustomerList.csv to customers table."""
    print("Importing CustomerList.csv...")
    
    try:
        customer_df = pd.read_csv('sqlproducts/CustomerList.csv')
        imported_count = 0
        error_count = 0
        
        for _, row in customer_df.iterrows():
            try:
                # Check if customer exists
                cursor.execute("SELECT customer_id FROM customers WHERE customer_id = %s", (row['CustomerNumber'],))
                customer_exists = cursor.fetchone()
                
                if customer_exists:
                    # Update existing customer
                    cursor.execute("""
                        UPDATE customers SET
                            company_name = %s,
                            contact_name = %s,
                            address = %s,
                            city = %s,
                            province = %s,
                            postal_code = %s,
                            contact_phone = %s,
                            contact_email = NULL,
                            updated_at = CURRENT_TIMESTAMP
                        WHERE customer_id = %s
                    """, (
                        row['Company'],
                        row['Name'],
                        row['Address'],
                        row['City'],
                        row['Prov'],
                        row['Postal Code'],
                        row['Phone'],
                        row['CustomerNumber']
                    ))
                else:
                    # Insert new customer
                    cursor.execute("""
                        INSERT INTO customers 
                        (customer_id, company_name, contact_name, address, city, province, postal_code, contact_phone, contact_email) 
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, NULL)
                    """, (
                        row['CustomerNumber'],
                        row['Company'],
                        row['Name'],
                        row['Address'],
                        row['City'],
                        row['Prov'],
                        row['Postal Code'],
                        row['Phone']
                    ))
                imported_count += 1
                
                # Commit every 100 records to avoid large transactions
                if imported_count % 100 == 0:
                    conn.commit()
                    print(f"Imported {imported_count} customers so far...")
                    
            except Exception as e:
                error_count += 1
                print(f"Error importing customer {row['CustomerNumber']}: {e}")
        
        # Final commit
        conn.commit()
        print(f"Customer import completed: {imported_count} imported, {error_count} errors")
        
    except Exception as e:
        print(f"Error reading CustomerList.csv: {e}")
        conn.rollback()

def import_hazards(cursor, conn):
    """Import HazardList.csv to hazards table."""
    print("Importing HazardList.csv...")
    
    try:
        # First create the hazards table if it doesn't exist
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS hazards (
                hazard_pk INTEGER PRIMARY KEY,
                hazard_code VARCHAR(50) NOT NULL,
                description1 TEXT,
                description2 TEXT,
                description3 TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        conn.commit()
        
        hazard_df = pd.read_csv('sqlproducts/HazardList.csv')
        imported_count = 0
        error_count = 0
        
        for _, row in hazard_df.iterrows():
            try:
                # Check if hazard exists
                cursor.execute("SELECT hazard_pk FROM hazards WHERE hazard_pk = %s", (row['Hazard PK'],))
                hazard_exists = cursor.fetchone()
                
                if hazard_exists:
                    # Update existing hazard
                    cursor.execute("""
                        UPDATE hazards SET
                            hazard_code = %s,
                            description1 = %s,
                            description2 = %s,
                            description3 = %s,
                            updated_at = CURRENT_TIMESTAMP
                        WHERE hazard_pk = %s
                    """, (
                        row['Hazard Code'],
                        row['Description1'],
                        row['Description2'],
                        row['Description3'],
                        row['Hazard PK']
                    ))
                else:
                    # Insert new hazard
                    cursor.execute("""
                        INSERT INTO hazards 
                        (hazard_pk, hazard_code, description1, description2, description3) 
                        VALUES (%s, %s, %s, %s, %s)
                    """, (
                        row['Hazard PK'],
                        row['Hazard Code'],
                        row['Description1'],
                        row['Description2'],
                        row['Description3']
                    ))
                imported_count += 1
                
            except Exception as e:
                error_count += 1
                print(f"Error importing hazard {row['Hazard PK']}: {e}")
        
        # Commit all hazard changes
        conn.commit()
        print(f"Hazard import completed: {imported_count} imported, {error_count} errors")
        
    except Exception as e:
        print(f"Error reading HazardList.csv: {e}")
        conn.rollback()

def import_products(cursor, conn):
    """Import AllProducts.csv to products table."""
    print("Importing AllProducts.csv...")
    
    try:
        # Process in chunks due to large file size
        chunk_size = 1000
        total_imported = 0
        total_errors = 0
        
        # Read the file in chunks
        for chunk_num, chunk in enumerate(pd.read_csv('sqlproducts/AllProducts.csv', chunksize=chunk_size)):
            imported_count = 0
            error_count = 0
            
            for _, row in chunk.iterrows():
                try:
                    # Check if product exists in the database
                    cursor.execute("SELECT product_id FROM products WHERE product_id = %s", (row['ProductCode'],))
                    product_exists = cursor.fetchone()
                    
                    # Handle boolean values and nulls
                    requires_heating = False
                    if 'Heat' in row and pd.notna(row['Heat']):
                        requires_heating = str(row['Heat']).lower() == 'true'
                    
                    is_dangerous_good = False
                    hazard_pk = None
                    if 'HazardPK' in row and pd.notna(row['HazardPK']):
                        hazard_pk = row['HazardPK']
                        is_dangerous_good = True
                    
                    weight_kg = 0
                    if 'WeightPerUnit' in row and pd.notna(row['WeightPerUnit']):
                        try:
                            weight_kg = float(row['WeightPerUnit'])
                        except (ValueError, TypeError):
                            weight_kg = 0
                    
                    volume_cubic_m = 0
                    if 'CubeValuePerUnit' in row and pd.notna(row['CubeValuePerUnit']):
                        try:
                            volume_cubic_m = float(row['CubeValuePerUnit'])
                        except (ValueError, TypeError):
                            volume_cubic_m = 0
                    
                    if product_exists:
                        # Update existing product
                        cursor.execute("""
                            UPDATE products SET
                                name = %s,
                                description = %s,
                                weight_kg = %s,
                                volume_cubic_m = %s,
                                requires_heating = %s,
                                is_dangerous_good = %s,
                                tdg_number = %s,
                                updated_at = CURRENT_TIMESTAMP
                            WHERE product_id = %s
                        """, (
                            row['Description'],
                            row['Description'],
                            weight_kg,
                            volume_cubic_m,
                            requires_heating,
                            is_dangerous_good,
                            hazard_pk,  # Using hazard_pk as tdg_number for now
                            row['ProductCode']
                        ))
                    else:
                        # Insert new product
                        cursor.execute("""
                            INSERT INTO products 
                            (product_id, name, description, weight_kg, volume_cubic_m, 
                             requires_refrigeration, requires_heating, is_dangerous_good, tdg_number) 
                            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                        """, (
                            row['ProductCode'],
                            row['Description'],
                            row['Description'],
                            weight_kg,
                            volume_cubic_m,
                            False,  # No refrigeration info in CSV
                            requires_heating,
                            is_dangerous_good,
                            hazard_pk  # Using hazard_pk as tdg_number for now
                        ))
                    imported_count += 1
                    
                except Exception as e:
                    error_count += 1
                    print(f"Error importing product {row.get('ProductCode', 'unknown')}: {e}")
            
            # Commit after each chunk
            conn.commit()
            total_imported += imported_count
            total_errors += error_count
            print(f"Imported chunk {chunk_num+1}: {imported_count} products, {error_count} errors")
        
        print(f"Product import completed: {total_imported} imported, {total_errors} errors")
        
    except Exception as e:
        print(f"Error reading AllProducts.csv: {e}")
        conn.rollback()

def main():
    """Main function to import all CSV files."""
    print("Starting CSV to SQL import process...")
    
    try:
        # Get database connection
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Import customers
        import_customers(cursor, conn)
        
        # Import hazards
        import_hazards(cursor, conn)
        
        # Import products
        import_products(cursor, conn)
        
        print("All imports completed successfully!")
        
    except Exception as e:
        print(f"Error during import process: {e}")
        sys.exit(1)
    finally:
        # Close connection
        if 'cursor' in locals() and cursor:
            cursor.close()
        if 'conn' in locals() and conn:
            conn.close()

if __name__ == "__main__":
    main()
