#!/bin/bash

# validate-openvino-build.sh
# Local validation script for OpenVINO addon build configuration

set -e

echo "🔍 OpenVINO Build Validation Script"
echo "=================================="

# Function to check command availability
check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        echo "✅ $1 is available"
        return 0
    else
        echo "❌ $1 is not available"
        return 1
    fi
}

# Function to check OpenVINO installation
check_openvino() {
    if [ -n "$OPENVINO_DIR" ] && [ -d "$OPENVINO_DIR" ]; then
        echo "✅ OpenVINO found at: $OPENVINO_DIR"
        if [ -f "$OPENVINO_DIR/setupvars.sh" ]; then
            echo "✅ OpenVINO setupvars.sh found"
            return 0
        else
            echo "❌ OpenVINO setupvars.sh not found"
            return 1
        fi
    else
        echo "❌ OpenVINO not found (OPENVINO_DIR not set or directory doesn't exist)"
        return 1
    fi
}

# Function to validate build directory
validate_build() {
    if [ -d "build-openvino" ]; then
        echo "✅ Build directory exists"
        if [ -f "build-openvino/libwhisper.a" ] || [ -f "build-openvino/Release/whisper.lib" ]; then
            echo "✅ Whisper library built successfully"
            return 0
        else
            echo "❌ Whisper library not found in build directory"
            return 1
        fi
    else
        echo "❌ Build directory doesn't exist"
        return 1
    fi
}

# Function to validate addon build
validate_addon() {
    if [ -d "examples/addon.node/build/Release" ]; then
        if [ -f "examples/addon.node/build/Release/addon.node" ]; then
            echo "✅ Node.js addon built successfully"
            echo "📊 Addon file size: $(ls -lh examples/addon.node/build/Release/addon.node | awk '{print $5}')"
            return 0
        else
            echo "❌ Node.js addon not found"
            return 1
        fi
    else
        echo "❌ Addon build directory doesn't exist"
        return 1
    fi
}

# Function to test addon loading
test_addon_loading() {
    echo "🧪 Testing addon loading..."
    cd examples/addon.node
    
    if node -e "
        try {
            const addon = require('./build/Release/addon.node');
            console.log('✅ Addon loaded successfully!');
            console.log('Available methods:', Object.keys(addon));
            process.exit(0);
        } catch (error) {
            console.error('❌ Failed to load addon:', error.message);
            process.exit(1);
        }
    "; then
        echo "✅ Addon loading test passed"
        cd ../..
        return 0
    else
        echo "❌ Addon loading test failed"
        cd ../..
        return 1
    fi
}

# Main validation flow
main() {
    echo "📋 Checking system requirements..."
    
    # Check required tools
    all_good=true
    
    check_command "cmake" || all_good=false
    check_command "node" || all_good=false
    check_command "npm" || all_good=false
    
    # Check Node.js version
    node_version=$(node --version | sed 's/v//')
    major_version=$(echo $node_version | cut -d. -f1)
    if [ "$major_version" -ge 21 ]; then
        echo "✅ Node.js version $node_version (>=21.0.0 required)"
    else
        echo "❌ Node.js version $node_version (<21.0.0, upgrade required)"
        all_good=false
    fi
    
    # Check OpenVINO
    check_openvino || all_good=false
    
    if [ "$all_good" = false ]; then
        echo ""
        echo "❌ System requirements not met. Please install missing dependencies."
        exit 1
    fi
    
    echo ""
    echo "📦 Validating build artifacts..."
    
    # Validate builds
    validate_build || { echo "❌ Library build validation failed"; exit 1; }
    validate_addon || { echo "❌ Addon build validation failed"; exit 1; }
    
    echo ""
    echo "🧪 Running functional tests..."
    
    # Test addon loading
    test_addon_loading || { echo "❌ Addon loading test failed"; exit 1; }
    
    echo ""
    echo "🎉 All validations passed!"
    echo ""
    echo "📋 Build Summary:"
    echo "- OpenVINO: $(basename "$OPENVINO_DIR")"
    echo "- Node.js: $(node --version)"
    echo "- Addon: examples/addon.node/build/Release/addon.node"
    echo "- Platform: $(uname -s) $(uname -m)"
    
    return 0
}

# Run main function
main "$@"