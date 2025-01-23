#!/bin/bash

# Sign binary with entitlements
sign_binary() {
    local binary="$1"
    local entitlements="$2"
    
    echo "Signing $binary..."
    ldid -S"$entitlements" "$binary"
}

# Sign all components
sign_components() {
    local build_dir="$1"
    
    # Sign main binary
    sign_binary "$build_dir/TrollStore" "bins/merge_ent.plist"
    
    # Sign helper binaries
    for helper in "$build_dir"/*.dylib; do
        sign_binary "$helper" "bins/merge_ent.plist"
    done
}

# Main
if [ "$1" != "" ]; then
    sign_components "$1"
else
    echo "Usage: $0 <build_directory>"
    exit 1
fi
