#!/usr/bin/env python3

import json
import re
import subprocess
import sys
import urllib.error
import urllib.request
from contextlib import contextmanager
from pathlib import Path

# Package configuration
OWNER = "grpc-ecosystem"
REPO = "grpc-gateway"
NIX_FILE = "default.nix"

@contextmanager
def nix_file_backup(nix_file_path):
    """Context manager that creates a backup of the Nix file and restores it on exit."""
    backup_content = None
    try:
        # Read and backup original content
        with open(nix_file_path, 'r', encoding='utf-8') as f:
            backup_content = f.read()
        yield nix_file_path
    except Exception:
        # Restore original content on any exception
        if backup_content is not None:
            try:
                with open(nix_file_path, 'w', encoding='utf-8') as f:
                    f.write(backup_content)
            except IOError as restore_error:
                print(f"Critical error: Could not restore backup of {nix_file_path}: {restore_error}")
        raise
    finally:
        # Always restore original content at the end
        if backup_content is not None:
            try:
                with open(nix_file_path, 'w', encoding='utf-8') as f:
                    f.write(backup_content)
            except IOError as restore_error:
                print(f"Warning: Could not restore backup of {nix_file_path}: {restore_error}")

def validate_hash_format(hash_string):
    """Validate that a hash string follows the expected sha256- format."""
    if not hash_string:
        return False
    
    # Check for sha256- prefix and valid base64 characters
    sha256_pattern = r'^sha256-[A-Za-z0-9+/]+=*$'
    return bool(re.match(sha256_pattern, hash_string))

def get_latest_release():
    """Get the latest release information from GitHub API."""
    url = f"https://api.github.com/repos/{OWNER}/{REPO}/releases/latest"
    
    try:
        with urllib.request.urlopen(url) as response:
            data = json.loads(response.read().decode())
            return data["tag_name"]
    except urllib.error.URLError as e:
        print(f"Network error fetching latest release: {e}")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"JSON parsing error: {e}")
        sys.exit(1)

def get_current_version():
    """Extract current version from default.nix."""
    nix_file = Path(__file__).parent / NIX_FILE
    
    with open(nix_file, 'r', encoding='utf-8') as f:
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
    
    clean_version = version.lstrip('v')
    src_hash = get_hash_for_version(version)
    
    # Use context manager to safely modify the Nix file
    with nix_file_backup(nix_file):
        try:
            # Read current content
            with open(nix_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Update version and src hash
            content = re.sub(r'version = "[^"]+";', f'version = "{clean_version}";', content)
            content = re.sub(r'sha256 = "[^"]+";', f'sha256 = "{src_hash}";', content)
            
            # Set vendor hash to empty to trigger error that shows correct hash
            content = re.sub(r'vendorHash = "[^"]+";', 'vendorHash = "";', content)
            
            # Write modified content
            with open(nix_file, 'w', encoding='utf-8') as f:
                f.write(content)
            
            # Try to build, which will fail and show the correct vendor hash
            result = subprocess.run(
                ['nix-build', '-E', f'(import <nixpkgs> {{}}).callPackage ./{NIX_FILE} {{}}'],
                cwd=Path(__file__).parent,
                capture_output=True,
                text=True
            )
            
            # Extract vendor hash from error message
            error_output = result.stderr
            vendor_hash = None
            
            # Try different patterns to extract the hash
            hash_match = re.search(r'got:\s*(sha256-[A-Za-z0-9+/=]+)', error_output)
            if hash_match:
                vendor_hash = hash_match.group(1)
            else:
                # Alternative pattern
                hash_match = re.search(r'expected:\s*(sha256-[A-Za-z0-9+/=]+)', error_output)
                if hash_match:
                    vendor_hash = hash_match.group(1)
            
            # Validate the extracted hash format
            if vendor_hash and validate_hash_format(vendor_hash):
                return vendor_hash
            elif vendor_hash:
                print(f"Warning: Extracted hash '{vendor_hash}' has invalid format")
                return None
            else:
                print("Could not extract vendor hash from build output")
                print("Build stderr:", error_output)
                return None
                
        except (subprocess.CalledProcessError, OSError, IOError) as e:
            print(f"Error getting vendor hash: {e}")
            return None

def update_nix_file(version, src_hash, vendor_hash):
    """Update the default.nix file with new version and hashes."""
    nix_file = Path(__file__).parent / NIX_FILE
    
    with open(nix_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    clean_version = version.lstrip('v')
    
    # Update version
    content = re.sub(r'version = "[^"]+";', f'version = "{clean_version}";', content)
    
    # Update src hash
    content = re.sub(r'sha256 = "[^"]+";', f'sha256 = "{src_hash}";', content)
    
    # Update vendor hash
    if vendor_hash:
        content = re.sub(r'vendorHash = "[^"]+";', f'vendorHash = "{vendor_hash}";', content)
    
    with open(nix_file, 'w', encoding='utf-8') as f:
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