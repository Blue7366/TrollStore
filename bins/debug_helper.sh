#!/bin/bash

# Debug helper script for TrollStore
TOOLS_DIR="$(pwd)/bins"
DEBUG_DIR="${TOOLS_DIR}/debug"
LOG_DIR="${DEBUG_DIR}/logs"

# Create necessary directories
mkdir -p "${LOG_DIR}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Debug functions
analyze_binary() {
    local binary="$1"
    local output_file="${LOG_DIR}/binary_analysis.log"
    
    echo -e "${YELLOW}Analyzing binary: ${binary}${NC}"
    
    # Header analysis
    echo "=== Binary Header Analysis ===" > "${output_file}"
    "${TOOLS_DIR}/otool" -h "${binary}" >> "${output_file}"
    
    # Load commands
    echo -e "\n=== Load Commands ===" >> "${output_file}"
    "${TOOLS_DIR}/otool" -l "${binary}" >> "${output_file}"
    
    # Shared libraries
    echo -e "\n=== Shared Libraries ===" >> "${output_file}"
    "${TOOLS_DIR}/otool" -L "${binary}" >> "${output_file}"
    
    # Entitlements
    echo -e "\n=== Entitlements ===" >> "${output_file}"
    "${TOOLS_DIR}/ldid" -e "${binary}" >> "${output_file}"
    
    echo -e "${GREEN}Analysis complete. Check ${output_file}${NC}"
}

check_signature() {
    local binary="$1"
    local output_file="${LOG_DIR}/signature_check.log"
    
    echo -e "${YELLOW}Checking signature: ${binary}${NC}"
    
    # Check code signature
    codesign -vv "${binary}" > "${output_file}" 2>&1
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Signature valid${NC}"
    else
        echo -e "${RED}Signature invalid${NC}"
    fi
}

trace_binary() {
    local binary="$1"
    local output_file="${LOG_DIR}/trace.log"
    
    echo -e "${YELLOW}Starting binary trace: ${binary}${NC}"
    
    # Use LLDB to trace
    lldb -o "process launch --stop-at-entry" \
         -o "thread trace start" \
         -o "continue" \
         -o "thread trace dump" \
         "${binary}" > "${output_file}"
         
    echo -e "${GREEN}Trace complete. Check ${output_file}${NC}"
}

# Main debug function
debug_binary() {
    local binary="$1"
    
    if [ ! -f "${binary}" ]; then
        echo -e "${RED}Binary not found: ${binary}${NC}"
        exit 1
    fi
    
    # Run all debug checks
    analyze_binary "${binary}"
    check_signature "${binary}"
    trace_binary "${binary}"
    
    echo -e "${GREEN}Debug analysis complete. Check ${LOG_DIR} for results${NC}"
}

# Main
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <binary>"
    exit 1
fi

debug_binary "$1"
