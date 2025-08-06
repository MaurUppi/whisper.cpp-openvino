cmake_minimum_required(VERSION 3.10)
project(addon.node)

set(TARGET addon.node)

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

# Link against the built libraries from main build
link_directories("${CMAKE_CURRENT_SOURCE_DIR}/../../build-openvino/src")
link_directories("${CMAKE_CURRENT_SOURCE_DIR}/../../build-openvino/ggml/src")
link_directories("${CMAKE_CURRENT_SOURCE_DIR}/../../build-openvino/examples")

target_link_libraries(${TARGET} ${CMAKE_JS_LIB} 
    "${CMAKE_CURRENT_SOURCE_DIR}/../../build-openvino/src/libwhisper.a"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../build-openvino/ggml/src/libggml.a"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../build-openvino/examples/libcommon.a"
    ${CMAKE_THREAD_LIBS_INIT})

if(MSVC AND CMAKE_JS_NODELIB_DEF AND CMAKE_JS_NODELIB_TARGET)
    # Generate node.lib
    execute_process(COMMAND ${CMAKE_AR} /def:${CMAKE_JS_NODELIB_DEF} /out:${CMAKE_JS_NODELIB_TARGET} ${CMAKE_STATIC_LINKER_FLAGS})
endif()
