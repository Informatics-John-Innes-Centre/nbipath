#!/usr/bin/env bash

# ==============================================================================
#  Installation Script for the NBI Path Navigation Game
# ==============================================================================
#
#  This script will:
#  1.  Make the main game script (nbipath.sh) executable.
#  2.  Create the necessary directory structure for the game under /norwich.
#  3.  Create a symbolic link to the game in /usr/local/bin for easy access.
#
#  **NOTE:** This script requires administrator privileges (sudo) to run, as it
#  needs to create directories in the root filesystem and a symlink in a system
#  directory.

# --- Exit on any error ---
set -e

# --- Check for sudo privileges ---
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Please use 'sudo ./install.sh'"
   exit 1
fi

echo "Starting installation..."

# --- Find the absolute path of the script ---
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
GAME_SCRIPT="$SCRIPT_DIR/nbipath.sh"
CREATING_PATHS_SCRIPT="$SCRIPT_DIR/creating_paths.sh"

# --- Make the game script executable ---
echo "Making nbipath.sh executable..."
chmod +x "$GAME_SCRIPT"

# --- Create the directory structure ---
echo "Creating game map directories under /norwich..."
bash "$CREATING_PATHS_SCRIPT"

# --- Create the symbolic link ---
INSTALL_PATH="/usr/local/bin/nbipath"
echo "Creating symbolic link at $INSTALL_PATH..."
ln -sf "$GAME_SCRIPT" "$INSTALL_PATH"

echo ""
echo "✅ Installation complete!"
echo "You can now run the game by typing 'nbipath' in your terminal."
