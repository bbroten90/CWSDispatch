#!/bin/bash
# Script to test the Cloud Function locally

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Setting up virtual environment...${NC}"

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    python -m venv venv
    echo "Virtual environment created."
fi

# Activate virtual environment
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # Windows
    source venv/Scripts/activate
else
    # Linux/Mac
    source venv/bin/activate
fi

echo -e "${GREEN}Installing dependencies...${NC}"
pip install -r requirements.txt

echo -e "${GREEN}Running local test...${NC}"
python test_locally.py

# Deactivate virtual environment
deactivate

echo -e "${GREEN}Test completed.${NC}"
