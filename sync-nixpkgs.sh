#!/usr/bin/env bash

set -euo pipefail

# Script to sync nixpkgs version across all example flakes with the root flake
# Usage: ./sync-nixpkgs.sh [--dry-run] [--verbose]

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_FLAKE="$SCRIPT_DIR/flake.nix"
EXAMPLES_DIR="$SCRIPT_DIR/examples"

# Parse command line arguments
DRY_RUN=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--dry-run] [--verbose]"
            echo "  --dry-run   Show what would be changed without making changes"
            echo "  --verbose   Show detailed output"
            echo "  --help      Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_verbose() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${BLUE}[VERBOSE]${NC} $1"
    fi
}

# Function to extract nixpkgs URL from flake.nix
extract_nixpkgs_url() {
    local flake_file="$1"
    
    if [[ ! -f "$flake_file" ]]; then
        log_error "Flake file not found: $flake_file"
        return 1
    fi
    
    # Extract nixpkgs URL using grep and sed
    local nixpkgs_line
    nixpkgs_line=$(grep -E '^\s*nixpkgs\.url\s*=' "$flake_file" || echo "")
    
    if [[ -z "$nixpkgs_line" ]]; then
        log_error "No nixpkgs.url found in $flake_file"
        return 1
    fi
    
    # Extract the URL part (everything between quotes)
    local url
    url=$(echo "$nixpkgs_line" | sed -E 's/.*nixpkgs\.url\s*=\s*"([^"]+)".*/\1/')
    
    if [[ -z "$url" ]]; then
        log_error "Could not extract nixpkgs URL from: $nixpkgs_line"
        return 1
    fi
    
    echo "$url"
}

# Function to update nixpkgs URL in a flake.nix file
update_nixpkgs_url() {
    local flake_file="$1"
    local new_url="$2"
    
    log_verbose "Updating $flake_file with nixpkgs URL: $new_url"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "DRY RUN: Would update $flake_file"
        return 0
    fi
    
    # Create a backup
    cp "$flake_file" "$flake_file.backup"
    
    # Use sed to replace the nixpkgs.url line
    # This handles both variations: github:nixos/nixpkgs and github:NixOS/nixpkgs
    sed -i.tmp -E "s|(nixpkgs\.url\s*=\s*\")[^\"]+(\";)|\1$new_url\2|g" "$flake_file"
    
    # Remove the temporary file created by sed -i
    rm -f "$flake_file.tmp"
    
    # Verify the change was made
    local updated_url
    updated_url=$(extract_nixpkgs_url "$flake_file")
    
    if [[ "$updated_url" == "$new_url" ]]; then
        log_verbose "Successfully updated $flake_file"
        rm -f "$flake_file.backup"
        return 0
    else
        log_error "Failed to update $flake_file. Restoring backup."
        mv "$flake_file.backup" "$flake_file"
        return 1
    fi
}

# Function to process all example flakes
process_examples() {
    local root_nixpkgs_url="$1"
    local updated_count=0
    local error_count=0
    local skipped_count=0
    
    log_info "Processing example flakes..."
    
    # Find all flake.nix files in examples directory
    while IFS= read -r -d '' flake_file; do
        local example_name
        example_name=$(basename "$(dirname "$flake_file")")
        
        log_verbose "Processing example: $example_name"
        
        # Extract current nixpkgs URL
        local current_url
        if ! current_url=$(extract_nixpkgs_url "$flake_file"); then
            log_warning "Skipping $example_name: Could not extract nixpkgs URL"
            ((skipped_count++))
            continue
        fi
        
        log_verbose "Current URL in $example_name: $current_url"
        
        # Check if update is needed
        if [[ "$current_url" == "$root_nixpkgs_url" ]]; then
            log_verbose "Skipping $example_name: Already up to date"
            continue
        fi
        
        # Update the flake
        if update_nixpkgs_url "$flake_file" "$root_nixpkgs_url"; then
            log_success "Updated $example_name: $current_url -> $root_nixpkgs_url"
            ((updated_count++))
        else
            log_error "Failed to update $example_name"
            ((error_count++))
        fi
        
    done < <(find "$EXAMPLES_DIR" -name "flake.nix" -type f -print0)
    
    # Summary
    echo ""
    log_info "Summary:"
    log_info "  Updated: $updated_count"
    log_info "  Errors: $error_count" 
    log_info "  Skipped: $skipped_count"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_warning "This was a dry run. No files were actually modified."
    fi
    
    return $error_count
}

# Main execution
main() {
    log_info "Starting nixpkgs synchronization..."
    
    # Check if we're in the right directory
    if [[ ! -f "$ROOT_FLAKE" ]]; then
        log_error "Root flake.nix not found at: $ROOT_FLAKE"
        log_error "Please run this script from the bufrnix repository root"
        exit 1
    fi
    
    if [[ ! -d "$EXAMPLES_DIR" ]]; then
        log_error "Examples directory not found at: $EXAMPLES_DIR"
        exit 1
    fi
    
    # Extract root nixpkgs URL
    log_info "Extracting nixpkgs URL from root flake..."
    local root_nixpkgs_url
    if ! root_nixpkgs_url=$(extract_nixpkgs_url "$ROOT_FLAKE"); then
        log_error "Could not extract nixpkgs URL from root flake"
        exit 1
    fi
    
    log_info "Root nixpkgs URL: $root_nixpkgs_url"
    
    # Process all examples
    if process_examples "$root_nixpkgs_url"; then
        log_success "All examples processed successfully!"
        exit 0
    else
        log_error "Some examples failed to update"
        exit 1
    fi
}

# Run main function
main "$@"