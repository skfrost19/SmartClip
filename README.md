# SmartClip - Clipboard Manager

A powerful clipboard manager with global hotkey support, system tray integration, and persistent history.

## Features

- 📋 **Clipboard History** - Automatically saves everything you copy
- ⌨️ **Global Hotkeys** - Access clipboard history from anywhere (default: Ctrl+G)
- 🔄 **Alt+Tab Style Cycling** - Hold Ctrl and press G repeatedly to cycle through items
- 🔍 **Search** - Quickly find items in your clipboard history
- 💾 **Persistent Storage** - History survives restarts
- 🚀 **Run at Startup** - Optional auto-start with Windows/Linux
- 📌 **System Tray** - Minimizes to tray, always accessible

## Installation

### From Source

1. **Prerequisites:**
   - Python 3.10 or higher
   - [uv](https://github.com/astral-sh/uv) package manager (recommended)

2. **Clone and Install:**
   ```bash
   git clone https://github.com/skfrost19/Clipbuddy.git
   cd Clipbuddy
   uv sync
   ```

3. **Run:**
   ```bash
   uv run main.py
   ```

### From Executable

Download the pre-built executable from the [Releases](https://github.com/skfrost19/Clipbuddy/releases) page.

## Building Executables

### Prerequisites

```bash
# Install development dependencies (includes PyInstaller)
uv sync --dev
```

### Build for Your Platform

```bash
# Simple build (creates dist/SmartClip.exe on Windows or dist/SmartClip on Linux)
uv run python build.py

# Clean build (removes old artifacts first)
uv run python build.py --clean
```

### Alternative: Using PyInstaller Directly

```bash
# Using the spec file
uv run pyinstaller SmartClip.spec

# Or manual command
uv run pyinstaller --name=SmartClip --onefile --windowed --clean main.py
```

### Cross-Platform Building

**Note:** PyInstaller cannot cross-compile. You need to build on each target platform:

| Platform | Build On | Output |
|----------|----------|--------|
| Windows | Windows | `dist/SmartClip.exe` |
| Linux | Linux | `dist/SmartClip` |
| macOS | macOS | `dist/SmartClip.app` |

#### Building on Linux

```bash
# Install dependencies
sudo apt-get install python3-dev  # Debian/Ubuntu
# or
sudo dnf install python3-devel    # Fedora

# Build
uv sync --dev
uv run python build.py
```

#### Building on Windows

```powershell
# Build
uv sync --dev
uv run python build.py
```

## Usage

### Hotkeys

| Hotkey | Action |
|--------|--------|
| `Ctrl+G` | Open clipboard overlay (default, customizable) |
| `Ctrl+G` (hold Ctrl, press G again) | Cycle to next item |
| Release `Ctrl` | Paste selected item |
| `Esc` | Close overlay without pasting |
| `Enter` | Paste selected item |
| `↑` / `↓` | Navigate items |

### System Tray

- **Click/Double-click** tray icon to show window
- **Right-click** for menu:
  - Show Smart Clip
  - Settings
  - Exit

### Settings

Access via the "Settings" button or tray menu:

- **Run at startup** - Launch automatically when system starts
- **Show notifications** - Enable/disable tray notifications
- **Swap hotkey** - Customize the global hotkey
- **Clipboard stack size** - Maximum items to keep

## Data Storage

Your data is stored in:

| Platform | Location |
|----------|----------|
| Windows | `%APPDATA%\SmartClip\` |
| Linux | `~/.config/SmartClip/` |

Files:
- `clipboard_history.json` - Your clipboard history
- `settings.json` - Application settings

## Requirements

- Python 3.10+
- PyQt6
- keyboard (for global hotkeys)

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
