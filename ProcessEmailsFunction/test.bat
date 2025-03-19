@echo off
REM Script to test the Cloud Function locally on Windows

echo Setting up virtual environment...

REM Create virtual environment if it doesn't exist
if not exist venv (
    python -m venv venv
    echo Virtual environment created.
)

REM Activate virtual environment
call venv\Scripts\activate.bat

echo Installing dependencies...
pip install -r requirements.txt

echo Running local test...
python test_locally.py

REM Deactivate virtual environment
call venv\Scripts\deactivate.bat

echo Test completed.
