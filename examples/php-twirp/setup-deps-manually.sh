#!/usr/bin/env bash
set -euo pipefail

# This script sets up the PHP Twirp example manually
echo "Setting up PHP Twirp example manually..."

# Make sure the gen directory exists
mkdir -p gen/php

# Install Composer dependencies if needed
if [ ! -d "vendor" ]; then
    echo "Installing PHP dependencies..."
    composer install --no-interaction --ignore-platform-reqs
else
    echo "Vendor directory already exists, skipping composer install"
fi

# Create a polyfill for mbstring functions
cat > mbstring_polyfill.php << 'EOF'
<?php
// Simple polyfill for mbstring functions used in the Twirp client/server
if (!function_exists('mb_strlen')) {
    function mb_strlen($str) { return strlen($str); }
}
if (!function_exists('mb_substr')) {
    function mb_substr($str, $start, $length = null) { 
        return $length === null ? substr($str, $start) : substr($str, $start, $length); 
    }
}
EOF

echo "Setup complete! You can now run the example with:"
echo "  run-server    # In one terminal"
echo "  run-client    # In another terminal"