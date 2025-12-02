#!/bin/bash
# Build script for creating SmartClip AppImage
# This script must be run on a Linux system

set -e

APP_NAME="SmartClip"
APP_VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/appimage_build"
APP_DIR="$BUILD_DIR/$APP_NAME.AppDir"

echo "=== SmartClip AppImage Builder ==="
echo ""

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "Error: This script must be run on Linux"
    exit 1
fi

# Check for required tools
echo "Checking dependencies..."

if ! command -v python3 &> /dev/null; then
    echo "Error: python3 is required"
    exit 1
fi

# Check if appimagetool exists, download and extract if not
APPIMAGETOOL_APPIMAGE="$SCRIPT_DIR/appimagetool-x86_64.AppImage"
APPIMAGETOOL_DIR="$SCRIPT_DIR/appimagetool_extracted"
APPIMAGETOOL="$APPIMAGETOOL_DIR/AppRun"

if [ ! -f "$APPIMAGETOOL" ]; then
    echo "Downloading appimagetool..."
    wget -q "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage" -O "$APPIMAGETOOL_APPIMAGE"
    chmod +x "$APPIMAGETOOL_APPIMAGE"
    
    # Extract appimagetool to avoid FUSE requirement
    echo "Extracting appimagetool (to avoid FUSE requirement)..."
    cd "$SCRIPT_DIR"
    "$APPIMAGETOOL_APPIMAGE" --appimage-extract > /dev/null 2>&1
    mv squashfs-root "$APPIMAGETOOL_DIR"
    rm -f "$APPIMAGETOOL_APPIMAGE"
fi

# Clean previous build
echo "Cleaning previous build..."
rm -rf "$BUILD_DIR"
mkdir -p "$APP_DIR"

# Build the application with PyInstaller first
echo "Building application with PyInstaller..."
cd "$SCRIPT_DIR"

# Ensure dependencies are installed
if command -v uv &> /dev/null; then
    uv sync
    uv run pyinstaller --clean --noconfirm SmartClip.spec
else
    pip install -r requirements.txt 2>/dev/null || pip install PyQt6 keyboard pyinstaller
    pyinstaller --clean --noconfirm SmartClip.spec
fi

# Check if build succeeded
if [ ! -f "$SCRIPT_DIR/dist/SmartClip" ]; then
    echo "Error: PyInstaller build failed"
    exit 1
fi

# Create AppDir structure
echo "Creating AppDir structure..."
mkdir -p "$APP_DIR/usr/bin"
mkdir -p "$APP_DIR/usr/lib"
mkdir -p "$APP_DIR/usr/share/applications"
mkdir -p "$APP_DIR/usr/share/icons/hicolor/256x256/apps"
mkdir -p "$APP_DIR/usr/share/metainfo"

# Copy the executable
cp "$SCRIPT_DIR/dist/SmartClip" "$APP_DIR/usr/bin/"
chmod +x "$APP_DIR/usr/bin/SmartClip"

# Copy icon if exists
if [ -f "$SCRIPT_DIR/icon.png" ]; then
    cp "$SCRIPT_DIR/icon.png" "$APP_DIR/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png"
    cp "$SCRIPT_DIR/icon.png" "$APP_DIR/$APP_NAME.png"
else
    # Create a simple placeholder icon
    echo "Warning: icon.png not found, creating placeholder..."
    convert -size 256x256 xc:#455A64 -fill white -gravity center -pointsize 48 -annotate 0 "SC" "$APP_DIR/$APP_NAME.png" 2>/dev/null || \
    echo "Note: Install ImageMagick to create placeholder icon, or add icon.png manually"
fi

# Create .desktop file
echo "Creating desktop file..."
cat > "$APP_DIR/$APP_NAME.desktop" << EOF
[Desktop Entry]
Type=Application
Name=SmartClip
Comment=Smart Clipboard Manager with global hotkeys
Exec=SmartClip
Icon=SmartClip
Categories=Utility;
Terminal=false
StartupNotify=true
Keywords=clipboard;copy;paste;history;
EOF

# Copy desktop file to standard location too
cp "$APP_DIR/$APP_NAME.desktop" "$APP_DIR/usr/share/applications/"

# Create AppStream metadata
echo "Creating AppStream metadata..."
cat > "$APP_DIR/usr/share/metainfo/com.github.skfrost19.SmartClip.metainfo.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<component type="desktop-application">
  <id>com.github.skfrost19.SmartClip</id>
  <name>SmartClip</name>
  <summary>Smart Clipboard Manager</summary>
  <metadata_license>MIT</metadata_license>
  <project_license>MIT</project_license>
  <launchable type="desktop-id">SmartClip.desktop</launchable>
  <description>
    <p>
      A lightweight, cross-platform clipboard manager with global hotkey support,
      system tray integration, and persistent history.
    </p>
    <p>Features include:</p>
    <ul>
      <li>Clipboard history with persistent storage</li>
      <li>Global hotkey support (default: Ctrl+Q)</li>
      <li>Alt+Tab style navigation</li>
      <li>Search and filter clipboard history</li>
      <li>System tray integration</li>
      <li>Run at startup option</li>
    </ul>
  </description>
  <developer id="com.github.skfrost19">
    <name>skfrost19</name>
  </developer>
  <content_rating type="oars-1.1" />
  <provides>
    <binary>SmartClip</binary>
  </provides>
  <releases>
    <release version="1.0.0" date="2025-12-01">
      <description>
        <p>Initial release</p>
      </description>
    </release>
  </releases>
</component>
EOF

# Create AppRun script
echo "Creating AppRun script..."
cat > "$APP_DIR/AppRun" << 'EOF'
#!/bin/bash
SELF=$(readlink -f "$0")
HERE=${SELF%/*}
export PATH="${HERE}/usr/bin/:${PATH}"
export LD_LIBRARY_PATH="${HERE}/usr/lib/:${LD_LIBRARY_PATH}"
export XDG_DATA_DIRS="${HERE}/usr/share/:${XDG_DATA_DIRS}"
exec "${HERE}/usr/bin/SmartClip" "$@"
EOF
chmod +x "$APP_DIR/AppRun"

# Build the AppImage
echo "Building AppImage..."
cd "$BUILD_DIR"

# Set architecture
export ARCH=x86_64

# Run appimagetool
"$APPIMAGETOOL" "$APP_DIR" "$SCRIPT_DIR/dist/${APP_NAME}-${APP_VERSION}-x86_64.AppImage"

# Check if successful
if [ -f "$SCRIPT_DIR/dist/${APP_NAME}-${APP_VERSION}-x86_64.AppImage" ]; then
    echo ""
    echo "=== Build Successful ==="
    echo "AppImage created: dist/${APP_NAME}-${APP_VERSION}-x86_64.AppImage"
    echo ""
    echo "To run: chmod +x dist/${APP_NAME}-${APP_VERSION}-x86_64.AppImage && ./dist/${APP_NAME}-${APP_VERSION}-x86_64.AppImage"
else
    echo "Error: AppImage creation failed"
    exit 1
fi
