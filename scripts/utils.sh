#!/bin/bash

LOG_DIR="logs"
LOG_FILE="${LOG_DIR}/install_$(date +%Y%m%d_%H%M%S).log"

mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

run_command() {
    local command="$1"
    log "Running command: $command"
    eval "$command" 2>&1 | tee -a "$LOG_FILE"
    local exit_code=${PIPESTATUS[0]}
    if [ $exit_code -ne 0 ]; then
        log "Command failed with exit code $exit_code"
    fi
    return $exit_code
}
