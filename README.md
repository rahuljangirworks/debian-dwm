# Debian DWM Post-Installation

Personal dotfiles and post-installation scripts for setting up DWM on Debian-based systems.

![Demo](demo.png)

## Quick Start

```bash
# Clone the repository
git clone https://github.com/rahuljangirworks/debian-dwm.git
cd debian-dwm

# Run the installer
chmod +x install.sh
./install.sh
```

## What It Does

1. **Installs packages** - Nala, Xorg, DWM build dependencies, and common utilities
2. **Copies dotfiles** - Configurations for DWM, Rofi, Picom, Alacritty, Kitty, etc.
3. **Builds suckless tools** - Compiles DWM and slstatus from source
4. **Builds Picom** - Installs FT-Labs compositor with blur support

## Included Configurations

| Component | Description |
|-----------|-------------|
| **DWM** | Dynamic window manager |
| **slstatus** | Status bar for DWM |
| **Rofi** | Application launcher |
| **Picom** | Compositor (transparency/blur) |
| **Alacritty/Kitty** | GPU-accelerated terminals |
| **Fastfetch** | System info display |

## Requirements

- Debian-based system (Debian, Ubuntu, Mint, etc.)
- `sudo` access
- Git

## After Installation

1. Log out
2. Select "DWM" from your display manager
3. Or run `startx` if using `.xinitrc`

## Credits

- [drewgrif](https://github.com/drewgrif) - Package installation inspiration
- [ChrisTitusTech](https://github.com/ChrisTitusTech) - Linutil fallback
- [sevu11](https://github.com/sevu11) - Original project base
