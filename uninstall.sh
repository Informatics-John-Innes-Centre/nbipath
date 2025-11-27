#!/usr/bin/env bash

# ==============================================================================
#  Uninstallation Script for the NBI Path Navigation Game
# ==============================================================================
#
#  This script will:
#  1.  Remove the symbolic link from /usr/local/bin.
#  2.  Remove the game's directory structure from the root filesystem.
#
#  **NOTE:** This script requires administrator privileges (sudo) to run.

# --- Exit on any error ---
set -e

# --- Check for sudo privileges ---
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Please use 'sudo ./uninstall.sh'"
   exit 1
fi

echo "Starting uninstallation..."

# --- Remove the symbolic link ---
INSTALL_PATH="/usr/local/bin/nbipath"
if [ -L "$INSTALL_PATH" ]; then
    echo "Removing symbolic link at $INSTALL_PATH..."
    rm "$INSTALL_PATH"
else
    echo "Symbolic link not found at $INSTALL_PATH (already removed?)."
fi

# --- Remove the directory structure ---
GAME_MAP_DIR="/norwich"
if [ -d "$GAME_MAP_DIR" ]; then
    echo "Removing game map directories under $GAME_MAP_DIR..."
    echo "WARNING: This will delete the entire $GAME_MAP_DIR directory."
    read -p "Are you sure you want to continue? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$GAME_MAP_DIR"
        echo "Directory $GAME_MAP_DIR removed."
    else
        echo "Aborted. The directory $GAME_MAP_DIR was not removed."
    fi
else
    echo "Game map directory not found at $GAME_MAP_DIR (already removed?)."
fi

echo ""
echo "✅ Uninstallation complete!"
