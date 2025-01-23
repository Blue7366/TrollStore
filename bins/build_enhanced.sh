#!/bin/bash

# Enhanced build script for TrollStore

# Configuration
TROLLSTORE_ROOT="$(pwd)"
BUILD_DIR="${TROLLSTORE_ROOT}/build"
PACKAGE_DIR="${TROLLSTORE_ROOT}/packages"
TOOLS_DIR="${TROLLSTORE_ROOT}/bins"
SDK_DIR="${TROLLSTORE_ROOT}/sdks"

# Required tools
REQUIRED_TOOLS=(
    "ldid"
    "insert_dylib"
    "dpkg-deb"
    "otool"
    "choma"
    "zip"
    "unzip"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Verify tools
verify_tools() {
    echo "🔍 Verifying build tools..."
    for tool in "${REQUIRED_TOOLS[@]}"; do
        if [ -f "${TOOLS_DIR}/${tool}" ]; then
            chmod +x "${TOOLS_DIR}/${tool}"
            echo -e "${GREEN}✓${NC} Found ${tool}"
        else
            echo -e "${RED}✗${NC} Missing ${tool}"
            exit 1
        fi
    done
}

# Setup build environment
setup_environment() {
    echo "🛠 Setting up build environment..."
    
    # Create directories
    mkdir -p "${BUILD_DIR}"
    mkdir -p "${PACKAGE_DIR}"
    
    # Export paths
    export PATH="${TOOLS_DIR}:${PATH}"
    export THEOS_SDKS_PATH="${SDK_DIR}"
    
    # Verify SDK
    if [ ! -d "${SDK_DIR}" ]; then
        echo "📥 Downloading iOS SDK..."
        curl -L -o master.zip https://github.com/theos/sdks/archive/master.zip
        unzip -q master.zip
        mkdir -p "${SDK_DIR}"
        mv sdks-master/*.sdk "${SDK_DIR}/"
        rm -rf sdks-master master.zip
    fi
}

# Build components
build_components() {
    echo "🏗 Building TrollStore components..."
    
    # Main app
    echo "Building main app..."
    make clean
    make package FINALPACKAGE=1 DEBUG=0
    
    # Helper components
    echo "Building helper components..."
    cd Helper
    make clean
    make package
    cd ..
    
    # Root helper
    echo "Building root helper..."
    cd RootHelper
    make clean
    make package
    cd ..
}

# Sign components
sign_components() {
    echo "📝 Signing components..."
    
    # Sign main binary
    ldid -S"${TOOLS_DIR}/merge_ent.plist" "${BUILD_DIR}/TrollStore.app/TrollStore"
    
    # Sign helpers
    for helper in "${BUILD_DIR}"/*.dylib; do
        ldid -S"${TOOLS_DIR}/merge_ent.plist" "$helper"
    done
}

# Create final package
create_package() {
    echo "📦 Creating final package..."
    
    # Create IPA
    cd "${PACKAGE_DIR}"
    mkdir -p Payload
    cp -r "${BUILD_DIR}/TrollStore.app" Payload/
    zip -qr TrollStore.ipa Payload
    rm -rf Payload
    
    # Create DEB
    dpkg-deb --build "${BUILD_DIR}" "${PACKAGE_DIR}/trollstore.deb"
}

# Main build process
main() {
    echo "🚀 Starting TrollStore build process..."
    
    verify_tools
    setup_environment
    build_components
    sign_components
    create_package
    
    echo -e "${GREEN}✅ Build completed successfully!${NC}"
    echo "📱 Output files:"
    echo " - ${PACKAGE_DIR}/TrollStore.ipa"
    echo " - ${PACKAGE_DIR}/trollstore.deb"
}

# Run main process
main
