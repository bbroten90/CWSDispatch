#!/bin/bash
# Script to make all shell scripts executable

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Making all shell scripts executable...${NC}"

# Make all .sh files executable
chmod +x *.sh

echo -e "${GREEN}Done!${NC}"
echo "The following scripts are now executable:"
ls -l *.sh
