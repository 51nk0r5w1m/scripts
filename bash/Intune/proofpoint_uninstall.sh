#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

LOG="/var/log/uninstall_metaclient.log"
exec 1>> "$LOG" 2>&1

echo "$(date) | Starting MetaClient Uninstall"

META_PROCESS=("MetaClient" "meta-agent-service")
META_DAEMON="/Library/LaunchDaemons/com.metanetworks.macOSService.plist"

# Define all paths related to MetaClient
META_FILES=(
    "/Applications/MetaClient.app"
    "/Library/Application Support/MetaNetworks"
    "/Library/LaunchDaemons/com.metanetworks.macOSService.plist"
)

function terminate_processes() {
    for process in "${META_PROCESS[@]}"; do
        if pgrep -f "$process" >/dev/null; then
            pkill -f "$process" || true
        fi
    done
}

function unload_launchdaemon() {
    if [[ -e "$META_DAEMON" ]]; then
        launchctl bootout system "$META_DAEMON" 2>/dev/null || true
    fi
}

function remove_files() {
    for file in "${META_FILES[@]}"; do
        [[ -e "$file" || -d "$file" ]] && rm -rf "$file" || true
    done
}

function main() {
    terminate_processes
    unload_launchdaemon
    remove_files

    if [[ -d "/Applications/MetaClient.app" || -d "/Library/Application Support/MetaNetworks" ]]; then
        echo "$(date) | MetaClient removal failed"
        exit 1
    else
        echo "$(date) | MetaClient successfully uninstalled"
    fi
}

main
