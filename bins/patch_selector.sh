#!/bin/bash

# Automatic patch selector for TrollStore
TOOLS_DIR="$(pwd)/bins"
PATCHES_DIR="${TOOLS_DIR}/patches"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Source iOS version script
source "${TOOLS_DIR}/ios_version.sh"

# Get required patches
get_required_patches() {
    local ios_version="$1"
    local patch_config
    
    patch_config=$(get_patch_config "${ios_version}")
    
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    # Parse plist file
    /usr/libexec/PlistBuddy -c "Print :PatchConfigs:${ios_version}" "${patch_config}"
}

# Apply patches
apply_patches() {
    local binary="$1"
    local patches=("${@:2}")
    
    for patch in "${patches[@]}"; do
        echo -e "${YELLOW}Applying patch: ${patch}${NC}"
        
        "${TOOLS_DIR}/patch_binary.sh" "${binary}" "${patch}"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Successfully applied ${patch}${NC}"
        else
            echo -e "${RED}Failed to apply ${patch}${NC}"
            return 1
        fi
    done
}

# Verify patches
verify_patches() {
    local binary="$1"
    local patches=("${@:2}")
    
    echo -e "${YELLOW}Verifying patches...${NC}"
    
    "${TOOLS_DIR}/debug_helper.sh" "${binary}"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}All patches verified${NC}"
        return 0
    else
        echo -e "${RED}Patch verification failed${NC}"
        return 1
    fi
}

# Main
main() {
    if [ "$#" -lt 1 ]; then
        echo "Usage: $0 <binary>"
        exit 1
    fi
    
    local binary="$1"
    
    # Get iOS version
    local ios_version
    ios_version=$(get_ios_version)
    
    # Get required patches
    local patches
    patches=($(get_required_patches "${ios_version}"))
    
    if [ "${#patches[@]}" -eq 0 ]; then
        echo -e "${RED}No patches found for iOS ${ios_version}${NC}"
        exit 1
    fi
    
    # Apply patches
    apply_patches "${binary}" "${patches[@]}"
    
    # Verify patches
    verify_patches "${binary}" "${patches[@]}"
}

# Run main if not sourced
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    main "$@"
fi
