#!/bin/bash

# Dylib injection script for TrollStore
TOOLS_DIR="$(pwd)/bins"
DYLIB_DIR="${TOOLS_DIR}/dylibs"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Inject dylib into binary
inject_dylib() {
    local binary="$1"
    local dylib="$2"
    local backup="${binary}.backup"
    
    echo -e "${YELLOW}Injecting ${dylib} into ${binary}...${NC}"
    
    # Create backup
    cp "${binary}" "${backup}"
    
    # Inject dylib
    "${TOOLS_DIR}/insert_dylib" --all-yes "${dylib}" "${binary}"
    
    # Verify injection
    if "${TOOLS_DIR}/otool" -L "${binary}" | grep -q "${dylib}"; then
        echo -e "${GREEN}Successfully injected ${dylib}${NC}"
        return 0
    else
        echo -e "${RED}Failed to inject ${dylib}${NC}"
        mv "${backup}" "${binary}"
        return 1
    fi
}

# Inject multiple dylibs
inject_multiple() {
    local binary="$1"
    shift
    local dylibs=("$@")
    
    for dylib in "${dylibs[@]}"; do
        if [ ! -f "${dylib}" ]; then
            echo -e "${RED}Dylib not found: ${dylib}${NC}"
            continue
        fi
        
        inject_dylib "${binary}" "${dylib}"
    done
}

# Main function
main() {
    if [ "$#" -lt 2 ]; then
        echo "Usage: $0 <binary> <dylib1> [dylib2 ...]"
        exit 1
    fi
    
    local binary="$1"
    shift
    local dylibs=("$@")
    
    # Check binary exists
    if [ ! -f "${binary}" ]; then
        echo -e "${RED}Binary not found: ${binary}${NC}"
        exit 1
    fi
    
    # Inject dylibs
    inject_multiple "${binary}" "${dylibs[@]}"
}

# Run main with arguments
main "$@"
