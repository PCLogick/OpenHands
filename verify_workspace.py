#!/usr/bin/env python3
import os
import sys

def main():
    print("Workspace Verification Script")
    print("=============================")
    
    # Print current working directory
    print(f"Current working directory: {os.getcwd()}")
    
    # List files in the current directory
    print("\nFiles in current directory:")
    for item in os.listdir('.'):
        print(f"- {item}")
    
    # Check if we can access specific files
    test_files = ['test_file.txt', 'docker-compose.yml', 'agent_config.json']
    print("\nChecking access to specific files:")
    for file in test_files:
        if os.path.exists(file):
            print(f"✅ {file} exists and is accessible")
            with open(file, 'r') as f:
                first_line = f.readline().strip()
                print(f"   First line: {first_line}")
        else:
            print(f"❌ {file} does not exist or is not accessible")
    
    # Print environment variables
    print("\nEnvironment variables:")
    for key, value in os.environ.items():
        if 'PATH' in key or 'WORKSPACE' in key:
            print(f"- {key}: {value}")
    
    print("\nWorkspace verification complete.")

if __name__ == "__main__":
    main() 