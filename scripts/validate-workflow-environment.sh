#!/bin/bash

# validate-workflow-environment.sh
# Validation script for OpenVINO workflow environment setup

set -e

echo "🔍 OpenVINO Workflow Environment Validation"
echo "=========================================="

# Function to check if environment variable is set
check_env_var() {
    local var_name="$1"
    if [ -n "${!var_name}" ]; then
        echo "✅ $var_name: ${!var_name}"
        return 0
    else
        echo "❌ $var_name: Not set"
        return 1
    fi
}

# Function to check if path exists
check_path() {
    local path="$1"
    local description="$2"
    if [ -e "$path" ]; then
        echo "✅ $description: $path exists"
        return 0
    else
        echo "❌ $description: $path does not exist"
        return 1
    fi
}

# Function to check library availability
check_library() {
    local lib_name="$1"
    if ldconfig -p | grep -q "$lib_name"; then
        echo "✅ Library $lib_name found in system"
        return 0
    else
        echo "❌ Library $lib_name not found in system"
        return 1
    fi
}

echo "📋 Environment Variables:"
check_env_var "OPENVINO_INSTALL_DIR"
check_env_var "LD_LIBRARY_PATH"
check_env_var "OpenVINO_DIR"

echo ""
echo "📋 OpenVINO Installation:"
if [ -n "$OPENVINO_INSTALL_DIR" ]; then
    check_path "$OPENVINO_INSTALL_DIR" "OpenVINO install directory"
    check_path "$OPENVINO_INSTALL_DIR/runtime/cmake" "OpenVINO CMake files"
    check_path "$OPENVINO_INSTALL_DIR/runtime/lib/intel64" "OpenVINO libraries"
    check_path "$OPENVINO_INSTALL_DIR/runtime/3rdparty/tbb/lib" "OpenVINO TBB libraries"
    check_path "$OPENVINO_INSTALL_DIR/setupvars.sh" "OpenVINO setup script"
else
    echo "⚠️  OPENVINO_INSTALL_DIR not set, skipping OpenVINO path checks"
fi

echo ""
echo "📋 System Dependencies:"
check_library "libtbb"
check_library "libopenvino"

echo ""
echo "📋 Build Tools:"
if command -v cmake >/dev/null 2>&1; then
    cmake_version=$(cmake --version | head -1 | awk '{print $3}')
    echo "✅ CMake: $cmake_version"
else
    echo "❌ CMake: Not found"
fi

if command -v node >/dev/null 2>&1; then
    node_version=$(node --version)
    echo "✅ Node.js: $node_version"
else
    echo "❌ Node.js: Not found"
fi

if command -v npx >/dev/null 2>&1; then
    echo "✅ NPX: Available"
    if npx cmake-js --version >/dev/null 2>&1; then
        cmake_js_version=$(npx cmake-js --version 2>&1 | head -1)
        echo "✅ cmake-js: $cmake_js_version"
    else
        echo "❌ cmake-js: Not available"
    fi
else
    echo "❌ NPX: Not found"
fi

echo ""
echo "📋 Build Directories:"
check_path "build" "Whisper.cpp build directory"
check_path "examples/addon.node" "Node.js addon directory"

if [ -d "examples/addon.node" ]; then
    check_path "examples/addon.node/package.json" "Addon package.json"
    check_path "examples/addon.node/CMakeLists.txt" "Addon CMakeLists.txt"
fi

echo ""
echo "🎯 Validation Summary"
echo "===================="

# Count successful checks (simple approach)
if [ -n "$OPENVINO_INSTALL_DIR" ] && [ -d "$OPENVINO_INSTALL_DIR" ] && command -v cmake >/dev/null 2>&1 && command -v node >/dev/null 2>&1; then
    echo "✅ Core requirements satisfied"
else
    echo "❌ Core requirements not met"
fi

if ldconfig -p | grep -q "libtbb"; then
    echo "✅ TBB dependency resolved"
else
    echo "⚠️  TBB dependency may need attention"
fi

echo ""
echo "💡 Next Steps:"
echo "1. If any core requirements are missing, install them first"
echo "2. If TBB is missing, install libtbb-dev (Linux) or tbb (macOS)"
echo "3. Source the OpenVINO setup script if environment variables are missing"
echo "4. Run this script again to validate fixes"

exit 0