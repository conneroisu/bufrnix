#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track test results
FAILED_TESTS=()
PASSED_TESTS=()

echo -e "${YELLOW}Checking bufrnix example structures...${NC}"

# Function to check example structure
check_example() {
    local example_name=$1
    local example_dir="examples/$example_name"
    
    echo -e "${YELLOW}Checking $example_name...${NC}"
    
    # Check if example directory exists
    if [ ! -d "$example_dir" ]; then
        echo -e "${RED}✗ Example directory $example_dir does not exist${NC}"
        FAILED_TESTS+=("$example_name: directory not found")
        return 1
    fi
    
    # Check for required files
    local all_found=true
    
    # Check for flake.nix
    if [ -f "$example_dir/flake.nix" ]; then
        echo -e "  ${GREEN}✓${NC} Found: flake.nix"
    else
        echo -e "  ${RED}✗${NC} Missing: flake.nix"
        all_found=false
    fi
    
    # Check for proto directory
    if [ -d "$example_dir/proto" ]; then
        echo -e "  ${GREEN}✓${NC} Found: proto directory"
        # Check for at least one .proto file
        if find "$example_dir/proto" -name "*.proto" -type f | grep -q .; then
            echo -e "  ${GREEN}✓${NC} Found: .proto files"
        else
            echo -e "  ${RED}✗${NC} Missing: .proto files in proto directory"
            all_found=false
        fi
    else
        echo -e "  ${RED}✗${NC} Missing: proto directory"
        all_found=false
    fi
    
    if [ "$all_found" = true ]; then
        echo -e "${GREEN}✓ $example_name structure valid${NC}\n"
        PASSED_TESTS+=("$example_name")
        return 0
    else
        echo -e "${RED}✗ $example_name structure invalid${NC}\n"
        FAILED_TESTS+=("$example_name: invalid structure")
        return 1
    fi
}

# Check all examples
for example in examples/*/; do
    if [ -d "$example" ]; then
        example_name=$(basename "$example")
        check_example "$example_name" || true
    fi
done

# Summary
echo -e "\n${YELLOW}Structure Check Summary:${NC}"
echo -e "${GREEN}Passed: ${#PASSED_TESTS[@]}${NC}"
echo -e "${RED}Failed: ${#FAILED_TESTS[@]}${NC}"

if [ ${#PASSED_TESTS[@]} -gt 0 ]; then
    echo -e "\n${GREEN}Passed checks:${NC}"
    for test in "${PASSED_TESTS[@]}"; do
        echo -e "  ${GREEN}✓${NC} $test"
    done
fi

if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
    echo -e "\n${RED}Failed checks:${NC}"
    for test in "${FAILED_TESTS[@]}"; do
        echo -e "  ${RED}✗${NC} $test"
    done
    echo -e "\n${RED}Some checks failed!${NC}"
    exit 1
else
    echo -e "\n${GREEN}All structure checks passed!${NC}"
fi