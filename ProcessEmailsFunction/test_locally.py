#!/usr/bin/env python3
"""
Test script for running the Cloud Function locally.
This script simulates a Cloud Event trigger and calls the function.

To use:
1. Set up environment variables or modify this script with your test values
2. Run: python test_locally.py
"""

import os
import json
import base64
from main import process_gmail_orders

# Set environment variables for local testing
os.environ['LOCAL_DEVELOPMENT'] = 'true'
os.environ['PROJECT_ID'] = 'dispatch-dashboard-01'
os.environ['LOCATION'] = 'us-central1'
os.environ['PROCESSOR_ID'] = 'OrderReader'
os.environ['BUCKET_NAME'] = 'cwsorders'
os.environ['DB_USER'] = 'dispatch-admin'
os.environ['DB_PASSWORD'] = 'Lola443710!'  # For local testing only
os.environ['DB_NAME'] = 'dispatch-dashboard'
os.environ['DB_CONNECTION_NAME'] = 'dispatch-dashboard-01:northamerica-northeast1:dispatch-db'
os.environ['DB_HOST'] = '35.203.126.72'  # Cloud SQL IP address
os.environ['DB_PORT'] = '5432'  # PostgreSQL default port
os.environ['GMAIL_SECRET_ID'] = 'gmail-docai-credentials'
os.environ['DOCAI_SECRET_ID'] = 'docai-credentials'

# Create a mock Cloud Event
cloud_event = {
    "id": "1234567890",
    "source": "//pubsub.googleapis.com/projects/dispatch-dashboard-01/topics/process-emails-trigger",
    "specversion": "1.0",
    "type": "google.cloud.pubsub.topic.v1.messagePublished",
    "datacontenttype": "application/json",
    "time": "2025-03-11T12:00:00.000Z",
    "data": {
        "message": {
            "data": base64.b64encode(b'{"data":"trigger"}').decode('utf-8'),
            "messageId": "1234567890",
            "publishTime": "2025-03-11T12:00:00.000Z"
        },
        "subscription": "projects/dispatch-dashboard-01/subscriptions/process-emails-trigger-sub"
    }
}

# Create a mock context
class MockContext:
    def __init__(self):
        self.event_id = "1234567890"
        self.timestamp = "2025-03-11T12:00:00.000Z"
        self.event_type = "google.cloud.pubsub.topic.v1.messagePublished"
        self.resource = "projects/dispatch-dashboard-01/topics/process-emails-trigger"

# Call the function
print("Testing process_gmail_orders function locally...")
try:
    result = process_gmail_orders(cloud_event, MockContext())
    print(f"Function executed successfully with result: {result}")
except Exception as e:
    print(f"Error executing function: {str(e)}")
