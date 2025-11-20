"""
FastAPI application that generates JSON and serves it via RESTful API.
The JSON file is refreshed every hour.
"""
import json
import os
import time
import threading
from pathlib import Path
from datetime import datetime
from typing import Optional, Dict, Any
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
import uvicorn

app = FastAPI(title="JSON Data API", version="1.0.0")

# Configuration
JSON_FILE_PATH = os.getenv("JSON_FILE_PATH", "/app/data/reference.json")
DATA_DIR = Path(JSON_FILE_PATH).parent
DATA_DIR.mkdir(parents=True, exist_ok=True)

# Global variable to store loaded JSON data
json_data: Optional[Dict[str, Any]] = None
last_refresh_time: Optional[datetime] = None
refresh_lock = threading.Lock()


def generate_json() -> Dict[str, Any]:
    """
    Generate the JSON file with sample data.
    This function can be customized to generate your specific JSON structure.
    """
    return {
        "metadata": {
            "generated_at": datetime.now().isoformat(),
            "version": "1.0"
        },
        "data": {
            "items": [
                {"id": 1, "name": "Item 1", "value": 100},
                {"id": 2, "name": "Item 2", "value": 200},
                {"id": 3, "name": "Item 3", "value": 300}
            ],
            "summary": {
                "total_items": 3,
                "total_value": 600
            }
        }
    }


def load_json_file() -> bool:
    """
    Load JSON file from disk. Returns True if successful, False otherwise.
    """
    global json_data, last_refresh_time
    
    try:
        if os.path.exists(JSON_FILE_PATH):
            with open(JSON_FILE_PATH, 'r', encoding='utf-8') as f:
                json_data = json.load(f)
            last_refresh_time = datetime.now()
            print(f"JSON file loaded successfully at {last_refresh_time}")
            return True
        else:
            print(f"JSON file not found at {JSON_FILE_PATH}, generating new one...")
            # Generate initial JSON if file doesn't exist
            json_data = generate_json()
            save_json_file()
            return True
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON file: {e}")
        return False
    except Exception as e:
        print(f"Error loading JSON file: {e}")
        return False


def save_json_file():
    """
    Save the current json_data to disk.
    """
    try:
        with open(JSON_FILE_PATH, 'w', encoding='utf-8') as f:
            json.dump(json_data, f, indent=2, ensure_ascii=False)
        print(f"JSON file saved to {JSON_FILE_PATH}")
    except Exception as e:
        print(f"Error saving JSON file: {e}")


def refresh_json_periodically():
    """
    Background thread that refreshes the JSON file every hour.
    """
    while True:
        time.sleep(3600)  # Wait 1 hour
        print("Hourly refresh triggered - reloading JSON file...")
        with refresh_lock:
            load_json_file()


@app.on_event("startup")
async def startup_event():
    """
    Initialize the application on startup.
    """
    print("Starting API server...")
    # Load JSON file on startup
    load_json_file()
    
    # Start background thread for periodic refresh
    refresh_thread = threading.Thread(target=refresh_json_periodically, daemon=True)
    refresh_thread.start()
    print("Background refresh thread started (refreshes every hour)")


@app.get("/")
async def root():
    """
    Root endpoint - returns API information.
    """
    return {
        "service": "JSON Data API",
        "version": "1.0.0",
        "status": "running",
        "last_refresh": last_refresh_time.isoformat() if last_refresh_time else None
    }


@app.get("/health")
async def health():
    """
    Health check endpoint.
    """
    return {
        "status": "healthy",
        "json_loaded": json_data is not None,
        "last_refresh": last_refresh_time.isoformat() if last_refresh_time else None
    }


@app.get("/api/data")
async def get_all_data():
    """
    Get all JSON data.
    """
    with refresh_lock:
        if json_data is None:
            raise HTTPException(status_code=503, detail="JSON data not loaded")
        return JSONResponse(content=json_data)


@app.get("/api/data/{path:path}")
async def get_data_by_path(path: str):
    """
    Get specific section of JSON data by path.
    Example: /api/data/data/items/0 returns the first item
    """
    with refresh_lock:
        if json_data is None:
            raise HTTPException(status_code=503, detail="JSON data not loaded")
        
        # Navigate through the JSON structure using the path
        keys = path.split('/')
        result = json_data
        
        try:
            for key in keys:
                if key == '':
                    continue
                if isinstance(result, dict):
                    result = result[key]
                elif isinstance(result, list):
                    result = result[int(key)]
                else:
                    raise HTTPException(status_code=404, detail=f"Path not found: {path}")
            
            return JSONResponse(content=result)
        except (KeyError, ValueError, IndexError, TypeError) as e:
            raise HTTPException(status_code=404, detail=f"Path not found: {path}. Error: {str(e)}")


@app.post("/api/refresh")
async def manual_refresh():
    """
    Manually trigger a refresh of the JSON file.
    """
    with refresh_lock:
        success = load_json_file()
        if success:
            return {"status": "refreshed", "last_refresh": last_refresh_time.isoformat()}
        else:
            raise HTTPException(status_code=500, detail="Failed to refresh JSON file")


if __name__ == "__main__":
    # Run the API server
    port = int(os.getenv("API_PORT", "8000"))
    uvicorn.run(app, host="0.0.0.0", port=port)

