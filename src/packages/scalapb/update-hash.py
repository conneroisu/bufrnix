#!/usr/bin/env python3
import json
import subprocess
import urllib.request
import re
import sys

def get_latest_release():
    url = 'https://api.github.com/repos/scalapb/ScalaPB/releases/latest'
    with urllib.request.urlopen(url) as response:
        data = json.loads(response.read())
    return data['tag_name'].lstrip('v')

def get_jar_hash(version):
    url = f"https://github.com/scalapb/ScalaPB/releases/download/v{version}/scalapbc-{version}.zip"
    cmd = ['nix-prefetch-url', url]
    result = subprocess.run(cmd, capture_output=True, text=True)
    hash_legacy = result.stdout.strip().split('\n')[-1]
    
    # Convert to SRI format
    cmd_sri = ['nix-hash', '--to-sri', '--type', 'sha256', hash_legacy]
    result_sri = subprocess.run(cmd_sri, capture_output=True, text=True)
    return result_sri.stdout.strip()

def update_nix_file(version, jar_hash):
    import os
    nix_file = os.path.join(os.path.dirname(__file__), 'default.nix')
    
    with open(nix_file, 'r') as f:
        content = f.read()
    
    # Update version
    content = re.sub(
        r'version = "[^"]+";',
        f'version = "{version}";',
        content
    )
    
    # Update JAR hash
    content = re.sub(
        r'sha256 = "sha256-[^"]+";',
        f'sha256 = "{jar_hash}";',
        content
    )
    
    with open(nix_file, 'w') as f:
        f.write(content)

if __name__ == '__main__':
    print("Fetching latest ScalaPB release...")
    version = get_latest_release()
    print(f"Latest version: {version}")
    
    print("Calculating JAR distribution hash...")
    jar_hash = get_jar_hash(version)
    print(f"JAR hash: {jar_hash}")
    
    print("Updating default.nix...")
    update_nix_file(version, jar_hash)
    
    print("Done!")
    print("\nNote: ScalaPB uses the universal JAR distribution for cross-platform compatibility.")