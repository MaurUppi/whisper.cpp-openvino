#!/bin/bash

# test-workflow-config.sh
# Test script to validate GitHub Actions workflow configuration

set -e

echo "🧪 Testing OpenVINO Workflow Configuration"
echo "=========================================="

# Function to check if workflow file is valid YAML
validate_yaml() {
    local file="$1"
    echo "📋 Validating YAML syntax: $file"
    
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "
import yaml
import sys

try:
    with open('$file', 'r') as f:
        yaml.safe_load(f)
    print('✅ YAML syntax is valid')
except yaml.YAMLError as e:
    print(f'❌ YAML syntax error: {e}')
    sys.exit(1)
except Exception as e:
    print(f'❌ Error reading file: {e}')
    sys.exit(1)
"
    else
        echo "⚠️  Python3 not available, skipping YAML validation"
    fi
}

# Function to check workflow configuration
check_workflow_config() {
    local workflow_file=".github/workflows/openvino-build.yml"
    
    if [ ! -f "$workflow_file" ]; then
        echo "❌ Workflow file not found: $workflow_file"
        return 1
    fi
    
    echo "✅ Workflow file exists: $workflow_file"
    
    # Validate YAML syntax
    validate_yaml "$workflow_file"
    
    # Check for required components
    echo "📋 Checking workflow components..."
    
    local required_components=(
        "build-openvino-addons"
        "create-release"
        "windows-2022"
        "ubuntu-22.04"
        "macos-13"
        "addon-windows-openvino.node"
        "addon-linux-openvino.node"
        "addon-macos-openvino.node"
        "OpenVINO 2024.6.0"
    )
    
    for component in "${required_components[@]}"; do
        if grep -q "$component" "$workflow_file"; then
            echo "✅ Found: $component"
        else
            echo "❌ Missing: $component"
        fi
    done
    
    # Check OpenVINO URLs
    echo "📋 Checking OpenVINO download URLs..."
    
    local urls=(
        "https://storage.openvinotoolkit.org/repositories/openvino/packages/2024.6/windows/"
        "https://storage.openvinotoolkit.org/repositories/openvino/packages/2024.6/linux/"
        "https://storage.openvinotoolkit.org/repositories/openvino/packages/2024.6/macos/"
    )
    
    for url in "${urls[@]}"; do
        if grep -q "$url" "$workflow_file"; then
            echo "✅ Found URL: $url"
        else
            echo "❌ Missing URL: $url"
        fi
    done
}

# Function to test local directory structure
check_directory_structure() {
    echo "📋 Checking repository structure..."
    
    local required_dirs=(
        ".github/workflows"
        "examples/addon.node"
        "scripts"
    )
    
    local required_files=(
        "CMakeLists.txt"
        "examples/addon.node/package.json"
        "examples/addon.node/CMakeLists.txt"
        "scripts/validate-openvino-build.sh"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [ -d "$dir" ]; then
            echo "✅ Directory exists: $dir"
        else
            echo "❌ Directory missing: $dir"
        fi
    done
    
    for file in "${required_files[@]}"; do
        if [ -f "$file" ]; then
            echo "✅ File exists: $file"
        else
            echo "❌ File missing: $file"
        fi
    done
}

# Function to estimate build resources
estimate_build_resources() {
    echo "📋 Estimating build resources..."
    
    echo "💡 Expected build times:"
    echo "  - Windows: ~45-60 minutes"
    echo "  - Linux: ~30-45 minutes"
    echo "  - macOS: ~35-50 minutes"
    
    echo "💾 Expected artifact sizes:"
    echo "  - addon-windows-openvino.node: ~50-80 MB"
    echo "  - addon-linux-openvino.node: ~40-70 MB"
    echo "  - addon-macos-openvino.node: ~45-75 MB"
    
    echo "☁️  GitHub Actions usage:"
    echo "  - ~2-3 hours total build time per run"
    echo "  - ~500 MB-1 GB artifact storage per build"
}

# Function to check for potential issues
check_potential_issues() {
    echo "📋 Checking for potential issues..."
    
    # Check if we're in the right directory
    if [ ! -f "CMakeLists.txt" ] || [ ! -d "examples" ]; then
        echo "❌ Not in whisper.cpp root directory"
        return 1
    fi
    
    # Check for whisper.cpp OpenVINO support
    if grep -q "WHISPER_OPENVINO" CMakeLists.txt; then
        echo "✅ CMakeLists.txt has OpenVINO support"
    else
        echo "⚠️  CMakeLists.txt might not have OpenVINO support"
    fi
    
    # Check addon.node example
    if [ -f "examples/addon.node/addon.cpp" ]; then
        echo "✅ Node.js addon example exists"
    else
        echo "❌ Node.js addon example missing"
    fi
    
    # Check for cmake-js in addon package.json
    if grep -q "cmake-js" examples/addon.node/package.json; then
        echo "✅ cmake-js found in addon dependencies"
    else
        echo "❌ cmake-js missing from addon dependencies"
    fi
}

# Main test function
main() {
    echo "🚀 Starting workflow configuration test..."
    echo ""
    
    # Run all checks
    check_directory_structure
    echo ""
    
    check_workflow_config
    echo ""
    
    check_potential_issues
    echo ""
    
    estimate_build_resources
    echo ""
    
    echo "🎉 Workflow configuration test completed!"
    echo ""
    echo "📋 Next steps:"
    echo "1. Commit and push the workflow file to trigger first build"
    echo "2. Monitor GitHub Actions for build progress" 
    echo "3. Download artifacts from successful builds"
    echo "4. Test addons with SmartSub integration"
    
    return 0
}

# Run main function
main "$@"