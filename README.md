# whisper.cpp-openvino

High-performance [whisper.cpp](https://github.com/ggml-org/whisper.cpp) Node.js addons with **Intel OpenVINO GPU acceleration** support.

## 📋 Repository Information

- **Source Repository**: https://github.com/ggml-org/whisper.cpp
- **Upstream Fork**: https://github.com/buxuku/whisper.cpp
- **This Repository Goal**: Automated CI/CD builds for cross-platform OpenVINO Node.js addons

## 🚀 What This Provides

Cross-platform Node.js addons with OpenVINO GPU acceleration:

  - **Windows x64**: `addon-windows-openvino.node`
  - **Linux x64**: `addon-linux-openvino.node`  
  - **macOS ARM64**: `addon-macos-arm-openvino.node`
  - **macOS x64**: `addon-macos-x86-openvino.node`

## 📦 Download Pre-built Addons

**Default (OpenVINO 2024.6):** <-- Recommended by Whisper.cpp

  - Download from releases tagged with `default`
  - Optimized for stability and compatibility

**Latest (OpenVINO 2025.2):** <-- Intel PTL ready. 

  - Download from releases tagged with `latest`
  - Latest features and performance improvements

## 🔧 Compatibility

  - **OpenVINO**: 2024.6 (default) | 2025.2 (latest)
  - **Electron**: 30.1.0+
  - **Node.js**: 22+
  - **Hardware**: Intel Arc GPUs, Xe Graphics, Integrated Intel GPUs

## 🛠️ Build Instructions

See [OPENVINO_BUILD_README.md](OPENVINO_BUILD_README.md) for detailed build instructions and local development setup.

## ⚡ Performance (Assumptions ONLY)

**Expected GPU acceleration improvements:**

  - Intel Arc A770: ~3.5x speedup vs CPU
  - Intel Xe Graphics: ~2.0x speedup vs CPU  
  - Integrated Intel GPU: ~1.5-2.0x speedup vs CPU

---

**Build Status**: ![OpenVINO Build](../../actions/workflows/openvino-build.yml/badge.svg)