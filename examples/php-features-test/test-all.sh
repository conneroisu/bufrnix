#!/usr/bin/env bash
set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print test header
print_header() {
    echo -e "\n${YELLOW}========================================${NC}"
    echo -e "${YELLOW}Testing: $1${NC}"
    echo -e "${YELLOW}========================================${NC}\n"
}

# Function to print success
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to print error
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Function to test a configuration
test_config() {
    local config=$1
    local description=$2
    
    print_header "$description"
    
    # Enter the shell and run buf generate
    echo "Entering shell and generating code..."
    if nix develop .#$config -c bash -c "buf generate" 2>/dev/null; then
        print_success "Code generation successful"
    else
        print_error "Code generation failed"
        return 1
    fi
    
    # Check if files were generated
    local output_dir=""
    case $config in
        basic) output_dir="gen/php/basic" ;;
        grpc) output_dir="gen/php/grpc" ;;
        roadrunner) output_dir="gen/php/roadrunner" ;;
        laravel) output_dir="gen/php/laravel" ;;
        symfony) output_dir="gen/php/symfony" ;;
        async) output_dir="gen/php/async" ;;
        full) output_dir="gen/php/full" ;;
        clientOnly) output_dir="gen/php/client" ;;
    esac
    
    if [ -d "$output_dir" ]; then
        print_success "Output directory created: $output_dir"
        
        # Count generated files
        local file_count=$(find "$output_dir" -name "*.php" | wc -l)
        print_success "Generated $file_count PHP files"
        
        # Check for specific files based on configuration
        case $config in
            basic)
                # Check for message classes with custom namespace and prefix
                if [ -f "$output_dir/BasicTest/Messages/BTTestMessage.php" ]; then
                    print_success "Found message class with custom prefix"
                fi
                if [ -d "$output_dir/BasicTest/Meta" ]; then
                    print_success "Found custom metadata namespace"
                fi
                ;;
            
            grpc)
                # Check for gRPC service files
                if find "$output_dir" -name "*ServiceClient.php" | grep -q .; then
                    print_success "Found gRPC client files"
                fi
                if find "$output_dir" -name "*ServiceInterface.php" | grep -q .; then
                    print_success "Found gRPC service interfaces"
                fi
                ;;
            
            roadrunner)
                # Check for RoadRunner configuration
                if [ -f ".rr.yaml" ]; then
                    print_success "Found RoadRunner configuration"
                fi
                if [ -f "worker.php" ]; then
                    print_success "Found RoadRunner worker script"
                fi
                if [ -f "roadrunner-dev.sh" ]; then
                    print_success "Found RoadRunner dev script"
                fi
                ;;
            
            laravel)
                # Check for Laravel-specific files
                if [ -f "app/Providers/ProtobufServiceProvider.php" ]; then
                    print_success "Found Laravel service provider"
                fi
                if [ -f "app/Console/Commands/ProtobufGenerate.php" ]; then
                    print_success "Found Laravel artisan commands"
                fi
                if [ -f "config/grpc.php" ]; then
                    print_success "Found Laravel configuration"
                fi
                ;;
            
            symfony)
                # Check for Symfony-specific files
                if [ -f "src/Protobuf/ProtobufBundle.php" ]; then
                    print_success "Found Symfony bundle"
                fi
                if [ -f "src/Command/ProtobufGenerateCommand.php" ]; then
                    print_success "Found Symfony commands"
                fi
                if [ -f "src/MessageHandler/ProtobufMessageHandler.php" ]; then
                    print_success "Found Messenger handler"
                fi
                ;;
            
            async)
                # Check for async PHP examples
                if [ -f "$output_dir/Async/ReactPHPClient.php" ]; then
                    print_success "Found ReactPHP client"
                fi
                if [ -f "$output_dir/Async/SwooleGrpcServer.php" ]; then
                    print_success "Found Swoole server"
                fi
                if [ -f "$output_dir/Async/FiberProtobufHandler.php" ]; then
                    print_success "Found PHP Fibers handler"
                fi
                ;;
            
            full)
                # Check for all features
                if [ -f "composer.json" ]; then
                    print_success "Found composer.json"
                    
                    # Check composer.json contents
                    if grep -q "grpc/grpc" composer.json; then
                        print_success "Composer includes gRPC dependency"
                    fi
                    if grep -q "spiral/roadrunner-grpc" composer.json; then
                        print_success "Composer includes RoadRunner dependency"
                    fi
                    if grep -q "react/event-loop" composer.json; then
                        print_success "Composer includes ReactPHP dependency"
                    fi
                fi
                ;;
            
            clientOnly)
                # Check that only client files are generated
                if find "$output_dir" -name "*ServiceClient.php" | grep -q .; then
                    print_success "Found client files"
                fi
                if ! find "$output_dir" -name "*ServiceInterface.php" | grep -q .; then
                    print_success "No server interfaces (client-only mode)"
                fi
                ;;
        esac
        
        # Check namespace in generated files
        if [ -f "$output_dir"/*.php ] || find "$output_dir" -name "*.php" | head -1 > /dev/null; then
            local sample_file=$(find "$output_dir" -name "*.php" | head -1)
            if [ -n "$sample_file" ]; then
                echo "Checking namespace in: $sample_file"
                if grep -q "namespace" "$sample_file"; then
                    local namespace=$(grep "namespace" "$sample_file" | head -1)
                    print_success "Found namespace: $namespace"
                fi
            fi
        fi
        
    else
        print_error "Output directory not found: $output_dir"
        return 1
    fi
    
    return 0
}

# Main test execution
echo -e "${YELLOW}PHP Features Test Suite${NC}"
echo -e "${YELLOW}=======================${NC}"

# Clean up previous test runs
echo "Cleaning up previous test runs..."
rm -rf gen/
rm -rf app/ src/ config/
rm -f .rr.yaml worker.php roadrunner-dev.sh composer.json

# Create buf.gen.yaml if it doesn't exist
if [ ! -f "buf.gen.yaml" ]; then
    echo "Creating buf.gen.yaml..."
    cat > buf.gen.yaml << 'EOF'
version: v2
inputs:
  - directory: proto
EOF
fi

# Array of test configurations
declare -a tests=(
    "basic:Basic PHP protobuf with custom namespaces"
    "grpc:PHP with gRPC client/server support"
    "roadrunner:PHP with RoadRunner server"
    "laravel:Laravel framework integration"
    "symfony:Symfony framework integration"
    "async:Async PHP with ReactPHP, Swoole, and Fibers"
    "clientOnly:Client-only gRPC generation"
    "full:All features combined"
)

# Track test results
passed=0
failed=0

# Run each test
for test in "${tests[@]}"; do
    IFS=':' read -r config description <<< "$test"
    
    if test_config "$config" "$description"; then
        ((passed++))
    else
        ((failed++))
    fi
    
    # Clean up generated files for next test (except for 'full' which we'll inspect)
    if [ "$config" != "full" ]; then
        rm -rf gen/php/$config
        rm -rf app/ src/ config/
        rm -f .rr.yaml worker.php roadrunner-dev.sh
        [ "$config" != "basic" ] && rm -f composer.json
    fi
done

# Final summary
echo -e "\n${YELLOW}========================================${NC}"
echo -e "${YELLOW}Test Summary${NC}"
echo -e "${YELLOW}========================================${NC}"
echo -e "${GREEN}Passed: $passed${NC}"
echo -e "${RED}Failed: $failed${NC}"

if [ $failed -eq 0 ]; then
    echo -e "\n${GREEN}All tests passed! 🎉${NC}"
    
    # Show what was generated in the full test
    echo -e "\n${YELLOW}Full configuration generated files:${NC}"
    if [ -d "gen/php/full" ]; then
        echo "Message classes:"
        find gen/php/full -name "*.php" -not -path "*/Metadata/*" | head -5
        echo "..."
        echo -e "\nTotal files: $(find gen/php/full -name "*.php" | wc -l)"
    fi
else
    echo -e "\n${RED}Some tests failed. Please check the output above.${NC}"
    exit 1
fi