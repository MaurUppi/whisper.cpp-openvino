#!/bin/bash

# validate-workflow-environment.sh
# Simple validation script for OpenVINO workflow environment setup

echo "🔍 OpenVINO Workflow Environment Validation"
echo "=========================================="

echo ""
echo "📋 Environment Variables:"
echo "OPENVINO_INSTALL_DIR=${OPENVINO_INSTALL_DIR:-Not set}"
echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-Not set}"  
echo "OpenVINO_DIR=${OpenVINO_DIR:-Not set}"

echo ""
echo "📋 OpenVINO Installation:"
if [ -n "$OPENVINO_INSTALL_DIR" ]; then
    if [ -d "$OPENVINO_INSTALL_DIR" ]; then
        echo "✅ OpenVINO directory exists: $OPENVINO_INSTALL_DIR"
        
        if [ -f "$OPENVINO_INSTALL_DIR/setupvars.sh" ]; then
            echo "✅ Setup script found"
        else
            echo "⚠️  Setup script not found"
        fi
        
        if [ -d "$OPENVINO_INSTALL_DIR/runtime/cmake" ]; then
            echo "✅ CMake files found"
        else
            echo "⚠️  CMake files not found"
        fi
        
        if [ -d "$OPENVINO_INSTALL_DIR/runtime/lib/intel64" ]; then
            echo "✅ Runtime libraries directory found"
            lib_count=$(find "$OPENVINO_INSTALL_DIR/runtime/lib/intel64" -name "*.so*" 2>/dev/null | wc -l)
            echo "   Found $lib_count shared libraries"
        else
            echo "⚠️  Runtime libraries directory not found"
        fi
        
        if [ -d "$OPENVINO_INSTALL_DIR/runtime/3rdparty/tbb" ]; then
            echo "✅ Bundled TBB directory found"
        else
            echo "ℹ️  Bundled TBB directory not found (may use system TBB)"
        fi
        
    else
        echo "❌ OpenVINO directory does not exist: $OPENVINO_INSTALL_DIR"
    fi
else
    echo "❌ OPENVINO_INSTALL_DIR not set"
fi

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

if command -v npx >/dev/null 2>&1 && npx cmake-js --version >/dev/null 2>&1; then
    echo "✅ cmake-js: Available"
else
    echo "❌ cmake-js: Not available"
fi

echo ""
echo "📋 System TBB Libraries:"
if command -v ldconfig >/dev/null 2>&1; then
    if ldconfig -p 2>/dev/null | grep -q "libtbb"; then
        tbb_count=$(ldconfig -p 2>/dev/null | grep "libtbb" | wc -l)
        echo "✅ System TBB libraries found ($tbb_count entries)"
    else
        echo "ℹ️  System TBB libraries not found (will use bundled TBB)"
    fi
else
    echo "ℹ️  ldconfig not available (cannot check system libraries)"
fi

echo ""
echo "📋 Project Structure:"
if [ -f "CMakeLists.txt" ]; then
    echo "✅ Root CMakeLists.txt found"
else
    echo "⚠️  Root CMakeLists.txt not found"
fi

if [ -d "examples/addon.node" ]; then
    echo "✅ Node.js addon directory found"
    if [ -f "examples/addon.node/CMakeLists.txt" ]; then
        echo "✅ Addon CMakeLists.txt found"
    else
        echo "⚠️  Addon CMakeLists.txt not found"
    fi
else
    echo "⚠️  Node.js addon directory not found"
fi

echo ""
echo "🎯 Environment Summary:"
if [ -n "$OPENVINO_INSTALL_DIR" ] && [ -d "$OPENVINO_INSTALL_DIR" ]; then
    echo "✅ OpenVINO installation detected"
else
    echo "❌ OpenVINO installation not properly configured"
fi

if command -v cmake >/dev/null 2>&1 && command -v node >/dev/null 2>&1; then
    echo "✅ Build tools available"
else
    echo "❌ Build tools missing"
fi

echo ""
echo "💡 This validation is informational only - build will proceed regardless"
echo "🚀 Ready to continue with OpenVINO build process"

exit 0