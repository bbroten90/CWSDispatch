# Data Import and Email Processing Guide

This guide explains how to import your CSV data into the SQL database and how the email processing system has been updated to handle customer data properly.

## Overview of Changes

1. **Created an Import Script**: A new script `import_csv_to_sql.py` has been created to import your CSV data into the SQL database.
2. **Modified Email Processing**: The `main.py` file has been updated to handle customer lookups properly, preventing the "null value in column 'city'" errors.
3. **Added Required Dependencies**: Added pandas and python-dotenv to requirements.txt.

## Importing CSV Data

The `import_csv_to_sql.py` script will import the following CSV files into your SQL database:

- `CustomerList.csv` → `customers` table
- `HazardList.csv` → `hazards` table (creates this table if it doesn't exist)
- `All-Products-WithValues.csv` → `products` table

### Prerequisites

1. Make sure your CSV files are in the `sqlproducts/` directory:
   - `sqlproducts/CustomerList.csv`
   - `sqlproducts/HazardList.csv`
   - `sqlproducts/All-Products-WithValues.csv`

2. The script will use your existing `.env.yaml` file for configuration:
   ```yaml
   PROJECT_ID: 'dispatch-dashboard-01'
   DB_USER: 'dispatch-admin'
   DB_NAME: 'dispatch-dashboard'
   DB_CONNECTION_NAME: 'dispatch-dashboard-01:northamerica-northeast1:dispatch-db'
   DB_SECRET_ID: 'db-password'
   ```

3. The script will retrieve the database password from Google Secret Manager using the DB_SECRET_ID, just like your main.py file does. No need to set the DB_PASSWORD environment variable directly.

### Running the Import Script

1. Make sure you're in your virtual environment:
   ```bash
   cd ProcessEmailsFunction
   venv\Scripts\activate  # On Windows
   # OR
   source venv/bin/activate  # On macOS/Linux
   ```

2. Install the required dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Run the import script:
   ```bash
   python import_csv_to_sql.py
   ```

4. The script will:
   - Load configuration from your `.env.yaml` file
   - Retrieve the database password from Google Secret Manager
   - Connect to your Google Cloud SQL database
   - Import your CSV data

3. The script will:
   - Import customers from CustomerList.csv
   - Create a hazards table and import data from HazardList.csv
   - Import products from All-Products-WithValues.csv
   - Handle any duplicates by updating existing records

## Email Processing Changes

The `main.py` file has been modified to fix the issue with customer creation:

1. **Before**: The code was trying to create new customers with only customer_id and company_name, which violated the not-null constraint for the city field.

2. **After**: The code now:
   - Looks up customers by ID in the database
   - If the customer exists, it uses that customer for the order
   - If the customer doesn't exist, it logs a warning and continues processing the order (if possible)
   - Optionally skips orders with missing customers if REQUIRE_CUSTOMER=true is set

### Configuration Options

You can set the following environment variables to control the behavior:

- `REQUIRE_CUSTOMER`: Set to "true" to skip processing orders where the customer is not found in the database. Default is "false".

## Troubleshooting

### Import Issues

- If you encounter errors during import, check the error messages for specific issues.
- For large files, the import is done in chunks to avoid memory issues.
- If a specific record fails to import, the script will log the error and continue with the next record.

### Email Processing Issues

- If you still see errors about null values in the customers table, make sure you've imported the CustomerList.csv file first.
- Check the logs for warnings about customers not found in the database.
- If you want to require customers to exist before processing orders, set REQUIRE_CUSTOMER=true.

## Next Steps

1. Run the import script to load all your CSV data into the database.
2. Test the email processing to ensure it works correctly with the imported data.
3. Monitor the logs for any warnings or errors.
