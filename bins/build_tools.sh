#!/bin/bash

# Set permissions for binaries
chmod +x bins/ldid
chmod +x bins/choma
chmod +x bins/unzip

# Environment setup
export PATH="$PWD/bins:$PATH"
export THEOS_SDKS_PATH="$PWD/sdks"
export TROLLSTORE_ROOT="$PWD"

# Verify tools
echo "Verifying build tools..."
ldid -v
choma -v
unzip -v

# Setup build environment
setup_build_env() {
    # Create necessary directories
    mkdir -p build
    mkdir -p packages

    # Copy entitlements
    cp bins/merge_ent.plist build/

    # Verify SDK presence
    if [ ! -d "sdks" ]; then
        echo "Downloading iOS SDKs..."
        curl -L -o master.zip https://github.com/theos/sdks/archive/master.zip
        unzip master.zip
        mkdir -p sdks
        mv sdks-master/*.sdk sdks/
        rm -rf sdks-master master.zip
    fi
}

# Main
setup_build_env
