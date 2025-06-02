#!/usr/bin/env python3

import json
import re
import subprocess
import sys
import urllib.request
from pathlib import Path

# Package configuration
OWNER = "mfridman"
REPO = "protoc-gen-go-json"
NIX_FILE = "default.nix"

def get_latest_release():
    """Get the latest release information from GitHub API."""
    url = f"https://api.github.com/repos/{OWNER}/{REPO}/releases/latest"
    
    try:
        with urllib.request.urlopen(url) as response:
            data = json.loads(response.read().decode())
            return data["tag_name"]
    except Exception as e:
        print(f"Error fetching latest release: {e}")
        sys.exit(1)

def get_current_version():
    """Extract current version from default.nix."""
    nix_file = Path(__file__).parent / NIX_FILE
    
    with open(nix_file, 'r') as f:
        content = f.read()
    
    version_match = re.search(r'version = "([^"]+)"', content)
    if not version_match:
        print("Could not find version in default.nix")
        sys.exit(1)
    
    return version_match.group(1)

def get_hash_for_version(version):
    """Get the hash for a specific version using nix-prefetch-url."""
    url = f"https://github.com/{OWNER}/{REPO}/archive/{version}.tar.gz"
    
    try:
        # First get the hash using nix-prefetch-url
        result = subprocess.run(
            ['nix-prefetch-url', '--unpack', url],
            capture_output=True,
            text=True,
            check=True
        )
        old_hash = result.stdout.strip()
        
        # Convert to sha256- format using nix hash
        result = subprocess.run(
            ['nix', 'hash', 'to-sri', '--type', 'sha256', old_hash],
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error getting hash: {e}")
        sys.exit(1)

def get_vendor_hash(version):
    """Get the vendor hash by attempting to build with an empty hash."""
    nix_file = Path(__file__).parent / NIX_FILE
    
    # First, temporarily update the version and src hash
    with open(nix_file, 'r') as f:
        content = f.read()
    
    clean_version = version.lstrip('v')
    src_hash = get_hash_for_version(version)
    
    # Update version and src hash
    content = re.sub(r'version = "[^"]+";', f'version = "{clean_version}";', content)
    content = re.sub(r'sha256 = "[^"]+";', f'sha256 = "{src_hash}";', content)
    
    # Set vendor hash to empty to trigger error that shows correct hash
    content = re.sub(r'vendorHash = "[^"]+";', 'vendorHash = "";', content)
    
    with open(nix_file, 'w') as f:
        f.write(content)
    
    try:
        # Try to build, which will fail and show the correct vendor hash
        result = subprocess.run(
            ['nix-build', '-E', f'(import <nixpkgs> {{}}).callPackage ./{NIX_FILE} {{}}'],
            cwd=Path(__file__).parent,
            capture_output=True,
            text=True
        )
        
        # Extract vendor hash from error message
        error_output = result.stderr
        hash_match = re.search(r'got:\s*sha256-([A-Za-z0-9+/=]+)', error_output)
        if hash_match:
            return f"sha256-{hash_match.group(1)}"
        
        # Alternative pattern
        hash_match = re.search(r'expected:\s*sha256-([A-Za-z0-9+/=]+)', error_output)
        if hash_match:
            return f"sha256-{hash_match.group(1)}"
            
        print("Could not extract vendor hash from build output")
        print("Build stderr:", error_output)
        return None
        
    except Exception as e:
        print(f"Error getting vendor hash: {e}")
        return None

def update_nix_file(version, src_hash, vendor_hash):
    """Update the default.nix file with new version and hashes."""
    nix_file = Path(__file__).parent / NIX_FILE
    
    with open(nix_file, 'r') as f:
        content = f.read()
    
    clean_version = version.lstrip('v')
    
    # Update version
    content = re.sub(r'version = "[^"]+";', f'version = "{clean_version}";', content)
    
    # Update src hash
    content = re.sub(r'sha256 = "[^"]+";', f'sha256 = "{src_hash}";', content)
    
    # Update vendor hash
    if vendor_hash:
        content = re.sub(r'vendorHash = "[^"]+";', f'vendorHash = "{vendor_hash}";', content)
    
    with open(nix_file, 'w') as f:
        f.write(content)

def main():
    print(f"Updating {REPO}...")
    
    current_version = get_current_version()
    latest_version = get_latest_release()
    
    print(f"Current version: {current_version}")
    print(f"Latest version: {latest_version}")
    
    if current_version == latest_version.lstrip('v'):
        print("Already up to date!")
        return
    
    print("Fetching new hashes...")
    src_hash = get_hash_for_version(latest_version)
    print(f"Source hash: {src_hash}")
    
    print("Getting vendor hash...")
    vendor_hash = get_vendor_hash(latest_version)
    if vendor_hash:
        print(f"Vendor hash: {vendor_hash}")
    else:
        print("Warning: Could not determine vendor hash, keeping existing one")
    
    update_nix_file(latest_version, src_hash, vendor_hash)
    print(f"Updated {NIX_FILE} to version {latest_version}")

if __name__ == "__main__":
    main()