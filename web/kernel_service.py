"""
FastAPI application that serves kernel catalog data and manifests via RESTful API.
This service only reads pre-generated JSON files (collated_manifests.json and package_index.json).
It does NOT perform any indexing, collation, or kernel discovery operations.
Indexing and collation must be performed separately using the kernel_indexer tool.
"""
import json
import os
import time
import threading
from pathlib import Path
from datetime import datetime
from typing import Optional, Dict, Any, List
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
import uvicorn

app = FastAPI(title="ICRN Kernel Manager API", version="1.0.0")

# Configuration
COLLATED_MANIFESTS_PATH = os.getenv("COLLATED_MANIFESTS_PATH", "/app/data/collated_manifests.json")
PACKAGE_INDEX_PATH = os.getenv("PACKAGE_INDEX_PATH", "/app/data/package_index.json")
KERNEL_ROOT = os.getenv("KERNEL_ROOT", "/app/data")
DATA_DIR = Path(COLLATED_MANIFESTS_PATH).parent
DATA_DIR.mkdir(parents=True, exist_ok=True)

# Global variable to store loaded data
collated_manifests: Optional[Dict[str, Any]] = None
package_index: Optional[Dict[str, Any]] = None
last_refresh_time: Optional[datetime] = None
refresh_lock = threading.Lock()


def load_data_files() -> bool:
    """
    Load required kernel data files from disk.
    Both collated_manifests.json and package_index.json are required.
    This function ONLY reads existing JSON files - it does NOT trigger indexing or collation.
    Returns True if both files loaded successfully, raises exception otherwise.
    """
    global collated_manifests, package_index, last_refresh_time
    
    errors = []
    
    # Load collated_manifests.json (required)
    if not os.path.exists(COLLATED_MANIFESTS_PATH):
        errors.append(f"Required file not found: {COLLATED_MANIFESTS_PATH}")
    else:
        try:
            with open(COLLATED_MANIFESTS_PATH, 'r', encoding='utf-8') as f:
                collated_manifests = json.load(f)
            # Validate format
            if "kernels" not in collated_manifests or not isinstance(collated_manifests["kernels"], list):
                errors.append(f"Invalid format in {COLLATED_MANIFESTS_PATH}: missing or invalid 'kernels' field")
            else:
                print(f"Collated manifests file loaded successfully")
                print(f"  Total kernels: {collated_manifests.get('total_kernels', 'unknown')}")
        except json.JSONDecodeError as e:
            errors.append(f"Error parsing collated manifests JSON file {COLLATED_MANIFESTS_PATH}: {e}")
        except Exception as e:
            errors.append(f"Error loading collated manifests file {COLLATED_MANIFESTS_PATH}: {e}")
    
    # Load package_index.json (required)
    if not os.path.exists(PACKAGE_INDEX_PATH):
        errors.append(f"Required file not found: {PACKAGE_INDEX_PATH}")
    else:
        try:
            with open(PACKAGE_INDEX_PATH, 'r', encoding='utf-8') as f:
                package_index = json.load(f)
            # Validate format
            if "packages" not in package_index or not isinstance(package_index["packages"], list):
                errors.append(f"Invalid format in {PACKAGE_INDEX_PATH}: missing or invalid 'packages' field")
            else:
                print(f"Package index file loaded successfully")
                print(f"  Total packages: {package_index.get('total_packages', 'unknown')}")
        except json.JSONDecodeError as e:
            errors.append(f"Error parsing package index JSON file {PACKAGE_INDEX_PATH}: {e}")
        except Exception as e:
            errors.append(f"Error loading package index file {PACKAGE_INDEX_PATH}: {e}")
    
    # If any errors occurred, raise exception
    if errors:
        error_msg = "Failed to load required data files:\n" + "\n".join(f"  - {e}" for e in errors)
        print(f"ERROR: {error_msg}")
        collated_manifests = None
        package_index = None
        raise RuntimeError(error_msg)
    
    last_refresh_time = datetime.now()
    return True


def refresh_data_periodically():
    """
    Background thread that reloads the data files from disk every hour.
    This only reads existing files - it does NOT trigger indexing or collation.
    """
    while True:
        time.sleep(3600)  # Wait 1 hour
        print("Hourly reload triggered - reading data files from disk...")
        with refresh_lock:
            try:
                load_data_files()
            except RuntimeError as e:
                print(f"ERROR during reload: {e}")


@app.on_event("startup")
async def startup_event():
    """
    Initialize the application on startup.
    """
    print("Starting ICRN Kernel Manager API server...")
    # Load data files on startup - will raise exception if files are missing
    try:
        load_data_files()
        print("All required data files loaded successfully")
    except RuntimeError as e:
        print(f"CRITICAL ERROR: {e}")
        print("Server will start but API endpoints will return errors until files are available")
    
    # Start background thread for periodic reload (reads files from disk only)
    refresh_thread = threading.Thread(target=refresh_data_periodically, daemon=True)
    refresh_thread.start()
    print("Background reload thread started (reads files from disk every hour, no indexing)")


@app.get("/")
async def root():
    """
    Root endpoint - returns API information.
    Note: This service only reads pre-generated JSON files and does not perform indexing.
    """
    return {
        "service": "ICRN Kernel Manager API",
        "version": "1.0.0",
        "status": "running",
        "note": "This service reads pre-generated files only - no indexing performed",
        "last_refresh": last_refresh_time.isoformat() if last_refresh_time else None
    }


@app.get("/health")
async def health():
    """
    Health check endpoint.
    """
    return {
        "status": "healthy" if (collated_manifests is not None and package_index is not None) else "unhealthy",
        "collated_manifests_loaded": collated_manifests is not None,
        "package_index_loaded": package_index is not None,
        "last_refresh": last_refresh_time.isoformat() if last_refresh_time else None
    }


@app.get("/api/languages")
async def get_languages():
    """
    Get list of all available languages.
    """
    with refresh_lock:
        if collated_manifests is None:
            raise HTTPException(status_code=503, detail="Collated manifests not loaded")
        
        languages = set()
        # Extract unique languages from collated manifests
        for kernel in collated_manifests.get("kernels", []):
            lang = kernel.get("language")
            if lang:
                languages.add(lang)
        
        if not languages:
            raise HTTPException(status_code=503, detail="No languages found in data")
        
        return JSONResponse(content={"languages": sorted(list(languages))})


@app.get("/api/kernels/{language}")
async def get_kernels_for_language(language: str):
    """
    Get all kernels for a specific language.
    """
    with refresh_lock:
        if collated_manifests is None:
            raise HTTPException(status_code=503, detail="Collated manifests not loaded")
        
        kernels_dict = {}  # kernel_name -> set of versions
        
        # Extract kernels from collated manifests
        for kernel in collated_manifests.get("kernels", []):
            if kernel.get("language") == language:
                kernel_name = kernel.get("kernel_name")
                kernel_version = kernel.get("kernel_version")
                if kernel_name and kernel_version:
                    if kernel_name not in kernels_dict:
                        kernels_dict[kernel_name] = set()
                    kernels_dict[kernel_name].add(kernel_version)
        
        if not kernels_dict:
            raise HTTPException(status_code=404, detail=f"Language '{language}' not found or has no kernels")
        
        kernels = [
            {"name": name, "versions": sorted(list(versions))}
            for name, versions in kernels_dict.items()
        ]
        
        return JSONResponse(content={"language": language, "kernels": kernels})


@app.get("/api/kernel/{language}/{kernel_name}/{version}")
async def get_kernel_details(language: str, kernel_name: str, version: str):
    """
    Get details for a specific kernel version.
    """
    with refresh_lock:
        if collated_manifests is None:
            raise HTTPException(status_code=503, detail="Collated manifests not loaded")
        
        # Find kernel in collated manifests
        for kernel in collated_manifests.get("kernels", []):
            if (kernel.get("language") == language and
                kernel.get("kernel_name") == kernel_name and
                kernel.get("kernel_version") == version):
                return JSONResponse(content={
                    "language": language,
                    "kernel_name": kernel_name,
                    "version": version,
                    "language_version": kernel.get("language_version", ""),
                    "package_count": kernel.get("package_count", 0),
                    "manifest_path": kernel.get("manifest_path", ""),
                    "indexed_date": kernel.get("indexed_date", "")
                })
        
        raise HTTPException(
            status_code=404,
            detail=f"Kernel '{kernel_name}' version '{version}' not found for language '{language}'"
        )


@app.get("/api/manifest/{language}/{kernel_name}/{version}")
async def get_kernel_manifest(language: str, kernel_name: str, version: str):
    """
    Get package manifest for a specific kernel version.
    """
    with refresh_lock:
        if collated_manifests is None:
            raise HTTPException(status_code=503, detail="Collated manifests not loaded")
        
        # Find kernel in collated manifests - packages are already included
        for kernel in collated_manifests.get("kernels", []):
            if (kernel.get("language") == language and
                kernel.get("kernel_name") == kernel_name and
                kernel.get("kernel_version") == version):
                # Return manifest structure with packages
                manifest_data = {
                    "kernel_name": kernel.get("kernel_name"),
                    "kernel_version": kernel.get("kernel_version"),
                    "language": kernel.get("language"),
                    "language_version": kernel.get("language_version"),
                    "indexed_date": kernel.get("indexed_date"),
                    "packages": kernel.get("packages", [])
                }
                return JSONResponse(content=manifest_data)
        
        raise HTTPException(
            status_code=404,
            detail=f"Kernel '{kernel_name}' version '{version}' not found for language '{language}'"
        )


@app.get("/api/package/{package_name}")
async def get_package_info(package_name: str):
    """
    Get information about a specific package, including which kernels contain it.
    Requires package_index.json.
    """
    with refresh_lock:
        if package_index is None:
            raise HTTPException(
                status_code=503,
                detail="Package index not loaded"
            )
        
        # Search for package in package index
        for package in package_index.get("packages", []):
            if package.get("name") == package_name:
                return JSONResponse(content={
                    "name": package.get("name"),
                    "kernel_count": package.get("kernel_count", 0),
                    "kernels": package.get("kernels", [])
                })
        
        raise HTTPException(
            status_code=404,
            detail=f"Package '{package_name}' not found"
        )


@app.get("/api/packages/search")
async def search_packages(query: str = ""):
    """
    Search for packages by name (case-insensitive partial match).
    Requires package_index.json.
    """
    with refresh_lock:
        if package_index is None:
            raise HTTPException(
                status_code=503,
                detail="Package index not loaded"
            )
        
        query_lower = query.lower()
        matching_packages = []
        
        for package in package_index.get("packages", []):
            package_name = package.get("name", "")
            if query_lower in package_name.lower():
                matching_packages.append({
                    "name": package_name,
                    "kernel_count": package.get("kernel_count", 0),
                    "kernels": package.get("kernels", [])
                })
        
        return JSONResponse(content={
            "query": query,
            "total_matches": len(matching_packages),
            "packages": matching_packages
        })


@app.post("/api/refresh")
async def manual_refresh():
    """
    Manually trigger a reload of the data files from disk.
    This only reads existing JSON files - it does NOT trigger indexing or collation.
    Indexing must be performed separately using the kernel_indexer tool.
    """
    with refresh_lock:
        try:
            load_data_files()
            return {
                "status": "reloaded",
                "message": "Data files reloaded from disk (no indexing performed)",
                "last_refresh": last_refresh_time.isoformat() if last_refresh_time else None
            }
        except RuntimeError as e:
            raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    # Run the API server
    port = int(os.getenv("API_PORT", "8000"))
    uvicorn.run(app, host="0.0.0.0", port=port)

