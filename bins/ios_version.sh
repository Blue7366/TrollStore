#!/bin/bash

# iOS version detection script
TOOLS_DIR="$(pwd)/bins"
CONFIG_DIR="${TOOLS_DIR}/config"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Version mapping
declare -A IOS_VERSIONS=(
    ["15.0"]="15_0"
    ["15.1"]="15_1"
    ["15.2"]="15_2"
    ["15.3"]="15_3"
    ["15.4"]="15_4"
    ["15.5"]="15_5"
    ["16.0"]="16_0"
    ["16.1"]="16_1"
    ["16.2"]="16_2"
    ["16.3"]="16_3"
    ["16.4"]="16_4"
    ["16.5"]="16_5"
    ["17.0"]="17_0"
    ["17.1"]="17_1"
    ["17.2"]="17_2"
)

# Get device iOS version
get_ios_version() {
    local version
    version=$(sw_vers -productVersion)
    echo "${version}"
}

# Check version compatibility
check_compatibility() {
    local version="$1"
    local major_version="${version%%.*}"
    
    if [ "${major_version}" -lt 15 ] || [ "${major_version}" -gt 17 ]; then
        echo -e "${RED}Unsupported iOS version: ${version}${NC}"
        return 1
    fi
    
    if [ "${major_version}" -eq 17 ]; then
        echo -e "${YELLOW}Warning: iOS 17 support is experimental${NC}"
    fi
    
    return 0
}

# Get patch configuration for version
get_patch_config() {
    local version="$1"
    local version_key="${IOS_VERSIONS[${version}]}"
    
    if [ -z "${version_key}" ]; then
        echo -e "${RED}No patch configuration for version ${version}${NC}"
        return 1
    fi
    
    local config_file="${CONFIG_DIR}/patches_${version_key}.plist"
    
    if [ ! -f "${config_file}" ]; then
        echo -e "${RED}Patch configuration file not found: ${config_file}${NC}"
        return 1
    fi
    
    echo "${config_file}"
}

# Main
main() {
    local ios_version
    ios_version=$(get_ios_version)
    
    echo -e "${YELLOW}Detected iOS version: ${ios_version}${NC}"
    
    if ! check_compatibility "${ios_version}"; then
        exit 1
    fi
    
    local patch_config
    patch_config=$(get_patch_config "${ios_version}")
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Using patch configuration: ${patch_config}${NC}"
        echo "${patch_config}"
    else
        exit 1
    fi
}

# Run main if not sourced
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    main
fi
