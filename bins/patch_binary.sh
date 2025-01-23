#!/bin/bash

# Binary patching script for TrollStore

TOOLS_DIR="$(pwd)/bins"
PATCHES_DIR="${TOOLS_DIR}/patches"

# Patch types
declare -A PATCHES=(
    ["sandbox"]="Disable sandbox restrictions"
    ["jit"]="Enable JIT compilation"
    ["dylib"]="Enable dynamic library loading"
    ["debugger"]="Enable debugger attachment"
    ["root"]="Enable root access"
)

# Patch binary
patch_binary() {
    local binary="$1"
    local patch_type="$2"
    
    echo "Patching binary: ${binary}"
    echo "Applying patch: ${patch_type}"
    
    case "${patch_type}" in
        "sandbox")
            # Patch sandbox
            "${TOOLS_DIR}/choma" --patch-sandbox "${binary}"
            ;;
        "jit")
            # Enable JIT
            "${TOOLS_DIR}/choma" --enable-jit "${binary}"
            ;;
        "dylib")
            # Enable dylib loading
            "${TOOLS_DIR}/insert_dylib" --all-yes "${binary}"
            ;;
        "debugger")
            # Enable debugger
            "${TOOLS_DIR}/choma" --enable-debug "${binary}"
            ;;
        "root")
            # Enable root
            "${TOOLS_DIR}/choma" --enable-root "${binary}"
            ;;
        *)
            echo "Unknown patch type: ${patch_type}"
            exit 1
            ;;
    esac
}

# Verify binary
verify_binary() {
    local binary="$1"
    
    echo "Verifying binary: ${binary}"
    
    # Check architecture
    "${TOOLS_DIR}/otool" -h "${binary}"
    
    # Check entitlements
    "${TOOLS_DIR}/ldid" -e "${binary}"
    
    # Check dynamic libraries
    "${TOOLS_DIR}/otool" -L "${binary}"
}

# Main function
main() {
    if [ "$#" -lt 2 ]; then
        echo "Usage: $0 <binary> <patch_type>"
        echo "Available patch types:"
        for patch in "${!PATCHES[@]}"; do
            echo "  ${patch}: ${PATCHES[${patch}]}"
        done
        exit 1
    fi
    
    local binary="$1"
    local patch_type="$2"
    
    # Verify binary exists
    if [ ! -f "${binary}" ]; then
        echo "Binary not found: ${binary}"
        exit 1
    fi
    
    # Create backup
    cp "${binary}" "${binary}.backup"
    
    # Apply patch
    patch_binary "${binary}" "${patch_type}"
    
    # Verify patched binary
    verify_binary "${binary}"
    
    echo "Patching completed successfully!"
}

# Run main function with arguments
main "$@"
