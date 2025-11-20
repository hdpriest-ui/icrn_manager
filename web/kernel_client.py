"""
Example Python script to interact with the nginx-json-api service.

This script demonstrates how to send requests to the API from outside the container
and handle JSON-formatted responses.

Usage:
    python kernel_client.py

Configuration:
    - Update BASE_URL to match your deployment method:
      * NodePort: http://<NODE_IP>:30080
      * Port-forward: http://localhost:8080
      * LoadBalancer: http://<EXTERNAL_IP>
"""

import requests
import json
import sys
from typing import Optional, Dict, Any


# Configuration - Update this based on your deployment method
BASE_URL = "http://localhost:8080"  # Default for port-forward
# Alternative options:
# BASE_URL = "http://<NODE_IP>:30080"  # For NodePort
# BASE_URL = "http://<EXTERNAL_IP>"    # For LoadBalancer

# Timeout for requests (in seconds)
REQUEST_TIMEOUT = 10


def make_request(method: str, endpoint: str, data: Optional[Dict] = None) -> Optional[Dict]:
    """
    Make an HTTP request to the API.
    
    Args:
        method: HTTP method (GET, POST, etc.)
        endpoint: API endpoint path
        data: Optional JSON data for POST requests
    
    Returns:
        JSON response as dictionary, or None if error occurred
    """
    url = f"{BASE_URL}{endpoint}"
    headers = {"Content-Type": "application/json"}
    
    try:
        if method.upper() == "GET":
            response = requests.get(url, headers=headers, timeout=REQUEST_TIMEOUT)
        elif method.upper() == "POST":
            response = requests.post(url, headers=headers, json=data, timeout=REQUEST_TIMEOUT)
        else:
            print(f"Unsupported HTTP method: {method}")
            return None
        
        # Check if request was successful
        response.raise_for_status()
        
        # Parse JSON response
        return response.json()
    
    except requests.exceptions.ConnectionError:
        print(f"Error: Could not connect to {url}")
        print("Make sure the API is running and accessible.")
        return None
    except requests.exceptions.Timeout:
        print(f"Error: Request to {url} timed out")
        return None
    except requests.exceptions.HTTPError as e:
        print(f"HTTP Error {response.status_code}: {e}")
        try:
            error_detail = response.json()
            print(f"Error details: {json.dumps(error_detail, indent=2)}")
        except:
            print(f"Response: {response.text}")
        return None
    except json.JSONDecodeError:
        print(f"Error: Invalid JSON response from {url}")
        print(f"Response: {response.text}")
        return None
    except Exception as e:
        print(f"Unexpected error: {e}")
        return None


def check_health():
    """Check the health status of the API."""
    print("\n" + "="*60)
    print("1. Health Check")
    print("="*60)
    
    result = make_request("GET", "/health")
    if result:
        print("API Health Status:")
        print(json.dumps(result, indent=2))
        return result.get("status") == "healthy"
    return False


def get_api_info():
    """Get API information."""
    print("\n" + "="*60)
    print("2. API Information")
    print("="*60)
    
    result = make_request("GET", "/")
    if result:
        print("API Information:")
        print(json.dumps(result, indent=2))
    return result


def get_all_data():
    """Get all JSON data from the API."""
    print("\n" + "="*60)
    print("3. Get All Data")
    print("="*60)
    
    result = make_request("GET", "/api/data")
    if result:
        print("All JSON Data:")
        print(json.dumps(result, indent=2))
    return result


def get_data_by_path(path: str):
    """
    Get specific section of JSON data by path.
    
    Args:
        path: Path to the data (e.g., "data/items/0", "metadata", "data/summary")
    """
    print("\n" + "="*60)
    print(f"4. Get Data by Path: {path}")
    print("="*60)
    
    result = make_request("GET", f"/api/data/{path}")
    if result:
        print(f"Data at path '{path}':")
        print(json.dumps(result, indent=2))
    return result


def manual_refresh():
    """Manually trigger a refresh of the JSON file."""
    print("\n" + "="*60)
    print("5. Manual Refresh")
    print("="*60)
    
    result = make_request("POST", "/api/refresh")
    if result:
        print("Refresh Status:")
        print(json.dumps(result, indent=2))
    return result


def main():
    """Main function to demonstrate API interactions."""
    print("="*60)
    print("Nginx JSON API Client Example")
    print("="*60)
    print(f"Base URL: {BASE_URL}")
    
    # Check if API is accessible
    if not check_health():
        print("\nAPI is not healthy or not accessible. Exiting.")
        sys.exit(1)
    
    # Get API information
    get_api_info()
    
    # Get all data
    all_data = get_all_data()
    
    if all_data:
        # Example: Get specific paths based on the sample data structure
        print("\n" + "="*60)
        print("Examples: Getting Specific Data Paths")
        print("="*60)
        
        # Get metadata
        get_data_by_path("metadata")
        
        # Get all items
        get_data_by_path("data/items")
        
        # Get first item (index 0)
        get_data_by_path("data/items/0")
        
        # Get summary
        get_data_by_path("data/summary")
        
        # Get a specific field from an item
        get_data_by_path("data/items/1/name")
    
    # Manual refresh example
    manual_refresh()
    
    print("\n" + "="*60)
    print("Example script completed!")
    print("="*60)


if __name__ == "__main__":
    main()

