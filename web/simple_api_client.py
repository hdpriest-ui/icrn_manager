"""
Simple example script to interact with the nginx-json-api service.

This is a minimal example showing basic API interactions.
"""

import requests
import json

# Update this URL based on your deployment
API_URL = "http://localhost:8080"  # For port-forward
# API_URL = "http://<NODE_IP>:30080"  # For NodePort

# Example 1: Health check
print("1. Health Check:")
response = requests.get(f"{API_URL}/health")
print(json.dumps(response.json(), indent=2))

# Example 2: Get all data
print("\n2. Get All Data:")
response = requests.get(f"{API_URL}/api/data")
data = response.json()
print(json.dumps(data, indent=2))

# Example 3: Get specific path (first item)
print("\n3. Get First Item:")
response = requests.get(f"{API_URL}/api/data/data/items/0")
print(json.dumps(response.json(), indent=2))

# Example 4: Manual refresh
print("\n4. Manual Refresh:")
response = requests.post(f"{API_URL}/api/refresh")
print(json.dumps(response.json(), indent=2))

