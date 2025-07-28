#!/bin/bash

# ICRN Manager Demo GIF Renderer
# This script renders all the demo GIFs using VHS and places them in the correct directory

set -e  # Exit on any error

# Configuration
DEMO_DIR="documentation/source/demo_resources"
VHS_BINARY="$(pwd)/vhs"
TAPE_FILES=(
    "icrn_libraries.tape"
    "icrn_lib_manager_use_case.tape"
    "icrn_manager_switch.tape"
    "icrn_libraries_use_Rbioconductor.tape"
    "icrn_libraries_use_pecan.tape"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}[$(date '+%H:%M:%S')] ${message}${NC}"
}

# Function to check if VHS is available
check_vhs() {
    if [ ! -f "$VHS_BINARY" ]; then
        print_status $RED "Error: VHS binary not found at $VHS_BINARY"
        exit 1
    fi
    
    if [ ! -x "$VHS_BINARY" ]; then
        print_status $RED "Error: VHS binary is not executable"
        exit 1
    fi
    
    print_status $GREEN "VHS binary found and executable"
}

# Function to check if demo directory exists
check_demo_dir() {
    if [ ! -d "$DEMO_DIR" ]; then
        print_status $RED "Error: Demo directory not found: $DEMO_DIR"
        exit 1
    fi
    
    print_status $GREEN "Demo directory found: $DEMO_DIR"
}

# Function to render a single GIF
render_gif() {
    local tape_file=$1
    local gif_name=$(basename "$tape_file" .tape).gif
    
    print_status $BLUE "Starting render for $tape_file..."
    
    # Change to demo directory for rendering
    cd "$DEMO_DIR"
    
    # Render the GIF using the VHS binary from the project root
    if "$VHS_BINARY" "$tape_file"; then
        print_status $GREEN "Successfully rendered $gif_name"
        
        # Check if GIF was created in current directory
        if [ -f "$gif_name" ]; then
            print_status $GREEN "GIF created in demo directory: $gif_name"
        else
            print_status $YELLOW "GIF may have been created in parent directory"
            # Check if it was created in the parent directory
            if [ -f "../$gif_name" ]; then
                print_status $GREEN "Found GIF in parent directory, moving to demo directory"
                mv "../$gif_name" "$gif_name"
            fi
        fi
    else
        print_status $RED "Failed to render $tape_file"
        return 1
    fi
    
    # Return to original directory
    cd - > /dev/null
}

# Function to move GIFs to correct location if needed
move_gifs() {
    print_status $BLUE "Checking for GIFs in current directory..."
    
    for tape_file in "${TAPE_FILES[@]}"; do
        local gif_name=$(basename "$tape_file" .tape).gif
        
        # Check if GIF exists in current directory
        if [ -f "$gif_name" ]; then
            print_status $YELLOW "Moving $gif_name to $DEMO_DIR/"
            mv "$gif_name" "$DEMO_DIR/"
        fi
    done
}

# Function to verify all GIFs were created
verify_gifs() {
    print_status $BLUE "Verifying all GIFs were created..."
    
    local missing_gifs=()
    
    for tape_file in "${TAPE_FILES[@]}"; do
        local gif_name=$(basename "$tape_file" .tape).gif
        local gif_path="$DEMO_DIR/$gif_name"
        
        if [ -f "$gif_path" ]; then
            local size=$(du -h "$gif_path" | cut -f1)
            print_status $GREEN "✓ $gif_name ($size)"
        else
            print_status $RED "✗ $gif_name (missing)"
            missing_gifs+=("$gif_name")
        fi
    done
    
    if [ ${#missing_gifs[@]} -eq 0 ]; then
        print_status $GREEN "All GIFs created successfully!"
    else
        print_status $RED "Missing GIFs: ${missing_gifs[*]}"
        return 1
    fi
}

# Function to render all GIFs in parallel
render_all_gifs_parallel() {
    print_status $BLUE "Starting parallel GIF rendering..."
    
    local pids=()
    local failed_renders=()
    
    # Start each GIF rendering process in the background
    for tape_file in "${TAPE_FILES[@]}"; do
        if [ ! -f "$DEMO_DIR/$tape_file" ]; then
            print_status $RED "Tape file not found: $DEMO_DIR/$tape_file"
            failed_renders+=("$tape_file")
            continue
        fi
        
        # Start the render process in the background
        render_gif "$tape_file" &
        local pid=$!
        pids+=($pid)
        
        print_status $BLUE "Started render for $tape_file (PID: $pid)"
    done
    
    # Wait for all background processes to complete
    print_status $BLUE "Waiting for all rendering processes to complete..."
    for pid in "${pids[@]}"; do
        wait $pid
        local exit_code=$?
        if [ $exit_code -ne 0 ]; then
            print_status $RED "Process $pid failed with exit code $exit_code"
            failed_renders+=("$pid")
        else
            print_status $GREEN "Process $pid completed successfully"
        fi
    done
    
    # Report any failures
    if [ ${#failed_renders[@]} -gt 0 ]; then
        print_status $RED "Some renders failed: ${failed_renders[*]}"
        return 1
    else
        print_status $GREEN "All parallel renders completed successfully!"
    fi
}

# Main execution
main() {
    print_status $BLUE "Starting ICRN Manager Demo GIF Rendering (Parallel Mode)"
    print_status $BLUE "========================================================"
    
    # Check prerequisites
    check_vhs
    check_demo_dir
    
    # Activate conda environment if available
    if command -v conda &> /dev/null; then
        print_status $BLUE "Activating conda environment 'term'..."
        source $(conda info --base)/etc/profile.d/conda.sh
        conda activate term
        print_status $GREEN "Conda environment activated"
    else
        print_status $YELLOW "Conda not found, proceeding without conda environment"
    fi
    
    # Render all GIFs in parallel
    render_all_gifs_parallel
    
    # Retry any missing GIFs (sequential retry for failed ones)
    print_status $BLUE "Checking for any missing GIFs and retrying..."
    for tape_file in "${TAPE_FILES[@]}"; do
        local gif_name=$(basename "$tape_file" .tape).gif
        local gif_path="$DEMO_DIR/$gif_name"
        
        if [ ! -f "$gif_path" ]; then
            print_status $YELLOW "Retrying $tape_file..."
            render_gif "$tape_file"
        fi
    done
    
    # Move any GIFs that were created in the wrong location
    move_gifs
    
    # Verify all GIFs were created
    verify_gifs
    
    print_status $GREEN "Demo GIF rendering completed!"
}

# Run main function
main "$@" 