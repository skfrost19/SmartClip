#!/bin/bash
# Cleanup script for SmartClip build artifacts
# This script removes all build-related files and directories

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== SmartClip Build Cleanup ==="
echo ""

# Function to safely remove directory/file
safe_remove() {
    if [ -e "$1" ]; then
        echo "Removing: $1"
        rm -rf "$1"
    fi
}

# PyInstaller build directories
safe_remove "$SCRIPT_DIR/build"
safe_remove "$SCRIPT_DIR/dist"

# AppImage build directory
safe_remove "$SCRIPT_DIR/appimage_build"

# PyInstaller cache
safe_remove "$SCRIPT_DIR/__pycache__"

# AppImage tool (optional - comment out if you want to keep it)
safe_remove "$SCRIPT_DIR/appimagetool-x86_64.AppImage"
safe_remove "$SCRIPT_DIR/appimagetool_extracted"

# Spec file backup (if any)
safe_remove "$SCRIPT_DIR/*.spec.bak"

# Python bytecode
find "$SCRIPT_DIR" -type f -name "*.pyc" -delete 2>/dev/null || true
find "$SCRIPT_DIR" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true

echo ""
echo "=== Cleanup Complete ==="
echo ""
echo "The following items have been removed:"
echo "  - build/              (PyInstaller build cache)"
echo "  - dist/               (Built executables)"
echo "  - appimage_build/     (AppImage build directory)"
echo "  - __pycache__/        (Python cache)"
echo "  - appimagetool*       (AppImage tools - will be re-downloaded on next build)"
echo ""
