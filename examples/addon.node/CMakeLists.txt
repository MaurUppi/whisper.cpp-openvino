cmake_minimum_required(VERSION 3.10)
project(addon.node)

set(TARGET addon)

# Set include paths to main whisper.cpp cmake directory
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../cmake")

# Base settings
#==================================================================
# env var supported by cmake-js
add_definitions(-DNAPI_VERSION=4)
include_directories(${CMAKE_JS_INC})

# Include whisper.cpp directories
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/../../include")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/../")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/../../ggml/include")
#==================================================================

add_library(${TARGET} SHARED ${CMAKE_JS_SRC} addon.cpp)
set_target_properties(${TARGET} PROPERTIES PREFIX "" SUFFIX ".node")

include(DefaultTargetOptions)

# Include N-API wrappers
#==================================================================
execute_process(COMMAND node -p "require('node-addon-api').include"
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        OUTPUT_VARIABLE NODE_ADDON_API_DIR
        )
string(REPLACE "\n" "" NODE_ADDON_API_DIR ${NODE_ADDON_API_DIR})
string(REPLACE "\"" "" NODE_ADDON_API_DIR ${NODE_ADDON_API_DIR})
target_include_directories(${TARGET} PRIVATE ${NODE_ADDON_API_DIR})
#==================================================================

# Determine build directory (check both build and build-openvino)
set(WHISPER_BUILD_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../build")

# Check for different library file patterns based on platform
if(WIN32)
    # Windows uses .lib files and different directory structure
    if(NOT EXISTS "${WHISPER_BUILD_DIR}/src/Release/whisper.lib" AND NOT EXISTS "${WHISPER_BUILD_DIR}/src/Debug/whisper.lib")
        set(WHISPER_BUILD_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../build-openvino")
    endif()
else()
    # Unix uses .a files
    if(NOT EXISTS "${WHISPER_BUILD_DIR}/src/libwhisper.a")
        set(WHISPER_BUILD_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../build-openvino")
    endif()
endif()

message(STATUS "Using build directory: ${WHISPER_BUILD_DIR}")

# Debug: List available library files
if(WIN32)
    file(GLOB_RECURSE ALL_LIBS "${WHISPER_BUILD_DIR}/*.lib")
else()
    file(GLOB_RECURSE ALL_LIBS "${WHISPER_BUILD_DIR}/*.a")
endif()
message(STATUS "Found library files:")
foreach(lib ${ALL_LIBS})
    message(STATUS "  ${lib}")
endforeach()

# Link against the built libraries from main build
if(WIN32)
    # Windows library directories
    link_directories("${WHISPER_BUILD_DIR}/src/Release")
    link_directories("${WHISPER_BUILD_DIR}/src/Debug")
    link_directories("${WHISPER_BUILD_DIR}/ggml/src/Release") 
    link_directories("${WHISPER_BUILD_DIR}/ggml/src/Debug")
    link_directories("${WHISPER_BUILD_DIR}/examples/Release")
    link_directories("${WHISPER_BUILD_DIR}/examples/Debug")
else()
    # Unix library directories
    link_directories("${WHISPER_BUILD_DIR}/src")
    link_directories("${WHISPER_BUILD_DIR}/ggml/src") 
    link_directories("${WHISPER_BUILD_DIR}/examples")
endif()

# Core libraries in correct linking order
if(WIN32)
    # Windows uses .lib files and may have Release/Debug subdirectories
    set(WHISPER_LIBS
        "${WHISPER_BUILD_DIR}/examples/Release/common.lib"
        "${WHISPER_BUILD_DIR}/src/Release/whisper.lib"
        "${WHISPER_BUILD_DIR}/ggml/src/Release/ggml.lib"
    )
    
    # Add ggml CPU backend libraries (Windows)
    if(EXISTS "${WHISPER_BUILD_DIR}/ggml/src/Release/ggml-cpu.lib")
        list(APPEND WHISPER_LIBS "${WHISPER_BUILD_DIR}/ggml/src/Release/ggml-cpu.lib")
    endif()
    
    # Add ggml base library (Windows)
    if(EXISTS "${WHISPER_BUILD_DIR}/ggml/src/Release/ggml-base.lib")
        list(APPEND WHISPER_LIBS "${WHISPER_BUILD_DIR}/ggml/src/Release/ggml-base.lib")
    endif()
else()
    # Unix uses .a files
    set(WHISPER_LIBS
        "${WHISPER_BUILD_DIR}/examples/libcommon.a"
        "${WHISPER_BUILD_DIR}/src/libwhisper.a"
        "${WHISPER_BUILD_DIR}/ggml/src/libggml.a"
    )
    
    # Add ggml CPU backend libraries (Unix)
    if(EXISTS "${WHISPER_BUILD_DIR}/ggml/src/libggml-cpu.a")
        list(APPEND WHISPER_LIBS "${WHISPER_BUILD_DIR}/ggml/src/libggml-cpu.a")
    endif()
    
    # Add ggml base library (Unix)  
    if(EXISTS "${WHISPER_BUILD_DIR}/ggml/src/libggml-base.a")
        list(APPEND WHISPER_LIBS "${WHISPER_BUILD_DIR}/ggml/src/libggml-base.a")
    endif()
endif()

# Check if this is an OpenVINO build
if(WHISPER_OPENVINO)
    message(STATUS "Building addon with OpenVINO support")
endif()

target_link_libraries(${TARGET} ${CMAKE_JS_LIB} 
    ${WHISPER_LIBS}
    ${CMAKE_THREAD_LIBS_INIT})

# Link OpenVINO runtime if building with OpenVINO support
if(WHISPER_OPENVINO)
    find_package(OpenVINO REQUIRED)
    target_link_libraries(${TARGET} openvino::runtime)
    message(STATUS "Linking addon with OpenVINO runtime")
endif()

if(MSVC AND CMAKE_JS_NODELIB_DEF AND CMAKE_JS_NODELIB_TARGET)
    # Generate node.lib
    execute_process(COMMAND ${CMAKE_AR} /def:${CMAKE_JS_NODELIB_DEF} /out:${CMAKE_JS_NODELIB_TARGET} ${CMAKE_STATIC_LINKER_FLAGS})
endif()
