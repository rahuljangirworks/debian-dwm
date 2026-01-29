#!/bin/bash

# Exit on error, undefined vars, and pipe failures
set -euo pipefail

# Colors
GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

# Error handler
trap 'echo -e "${RED}Error occurred on line $LINENO. Exiting.${NC}"; exit 1' ERR

# Get the directory where this script is located (works even when called from elsewhere)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define base directories
USER_HOME="$HOME"
CONFIG_DIR="$USER_HOME/.config"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"

echo -e "${YELLOW}============================================${NC}"
echo -e "${YELLOW}   Debian DWM Post-Installation Script${NC}"
echo -e "${YELLOW}============================================${NC}"
echo -e "${GREEN}User: $USER${NC}"
echo -e "${GREEN}Script Dir: $SCRIPT_DIR${NC}"
echo -e "${GREEN}Config Dir: $CONFIG_DIR${NC}"

# Validate directories exist
if [[ ! -d "$SCRIPTS_DIR" ]]; then
    echo -e "${RED}Scripts directory not found: $SCRIPTS_DIR${NC}"
    exit 1
fi

if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo -e "${RED}Dotfiles directory not found: $DOTFILES_DIR${NC}"
    exit 1
fi

# Create config directory
mkdir -p "$CONFIG_DIR"

echo -e "${GREEN}---------------------------------------------------${NC}"
echo -e "${GREEN}            Installing dependencies${NC}"
echo -e "${GREEN}---------------------------------------------------${NC}"

# Make scripts executable
chmod +x "$SCRIPTS_DIR/install_packages"
chmod +x "$SCRIPTS_DIR/install_nala"
chmod +x "$SCRIPTS_DIR/picom"

# Run package installation
cd "$SCRIPTS_DIR"
./install_packages

echo -e "${GREEN}---------------------------------------------------${NC}"
echo -e "${GREEN}       Moving dotfiles to correct location${NC}"
echo -e "${GREEN}---------------------------------------------------${NC}"

# Copy config directories
for dir in alacritty backgrounds fastfetch kitty picom rofi suckless; do
    if [[ -d "$DOTFILES_DIR/$dir" ]]; then
        echo -e "${YELLOW}Copying $dir...${NC}"
        cp -r "$DOTFILES_DIR/$dir" "$CONFIG_DIR/"
    fi
done

# Copy home directory files
if [[ -f "$DOTFILES_DIR/.bashrc" ]]; then
    echo -e "${YELLOW}Copying .bashrc...${NC}"
    cp "$DOTFILES_DIR/.bashrc" "$USER_HOME/"
fi

if [[ -d "$DOTFILES_DIR/.local" ]]; then
    echo -e "${YELLOW}Copying .local...${NC}"
    cp -r "$DOTFILES_DIR/.local" "$USER_HOME/"
fi

if [[ -f "$DOTFILES_DIR/.xinitrc" ]]; then
    echo -e "${YELLOW}Copying .xinitrc...${NC}"
    cp "$DOTFILES_DIR/.xinitrc" "$USER_HOME/"
fi

echo -e "${GREEN}---------------------------------------------------${NC}"
echo -e "${GREEN}            Fixing permissions${NC}"
echo -e "${GREEN}---------------------------------------------------${NC}"

# Fix permissions (exclude picom build directory which has root-owned files)
sudo chown -R "$USER":"$USER" "$CONFIG_DIR" 2>/dev/null || true
[[ -f "$USER_HOME/.bashrc" ]] && sudo chown "$USER":"$USER" "$USER_HOME/.bashrc"
[[ -f "$USER_HOME/.xinitrc" ]] && sudo chown "$USER":"$USER" "$USER_HOME/.xinitrc"

# Fix .local but exclude src (contains build files)
if [[ -d "$USER_HOME/.local" ]]; then
    # Fix bin and share
    [[ -d "$USER_HOME/.local/bin" ]] && sudo chown -R "$USER":"$USER" "$USER_HOME/.local/bin"
    [[ -d "$USER_HOME/.local/share" ]] && sudo chown -R "$USER":"$USER" "$USER_HOME/.local/share"
fi

echo -e "${GREEN}---------------------------------------------------${NC}"
echo -e "${GREEN}                 Updating Timezone${NC}"
echo -e "${GREEN}---------------------------------------------------${NC}"

if command -v dpkg-reconfigure &> /dev/null; then
    echo -e "${YELLOW}Configuring timezone (interactive)...${NC}"
    sudo dpkg-reconfigure tzdata || echo -e "${YELLOW}Timezone config skipped${NC}"
else
    echo -e "${YELLOW}dpkg-reconfigure not found. Skipping timezone.${NC}"
fi

echo -e "${GREEN}---------------------------------------------------${NC}"
echo -e "${GREEN}            Building DWM and SLStatus${NC}"
echo -e "${GREEN}---------------------------------------------------${NC}"

# Ensure DWM build dependencies are installed
echo -e "${YELLOW}Installing DWM build dependencies...${NC}"
sudo apt install -y build-essential libx11-dev libxft-dev libxinerama-dev libfreetype6-dev libfontconfig1-dev || true

# Build suckless tools
for tool in dwm slstatus; do
    TOOL_DIR="$CONFIG_DIR/suckless/$tool"
    if [[ -d "$TOOL_DIR" ]]; then
        echo -e "${YELLOW}Building $tool...${NC}"
        cd "$TOOL_DIR"
        sudo make clean install
    else
        echo -e "${RED}$tool directory not found: $TOOL_DIR${NC}"
    fi
done

echo -e "${GREEN}---------------------------------------------------${NC}"
echo -e "${GREEN}         Installation Complete!${NC}"
echo -e "${GREEN}---------------------------------------------------${NC}"

echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Log out and select DWM from your display manager"
echo -e "  2. Or run: startx (if using .xinitrc)"
echo ""

# Ask about reboot
read -r -p "Do you want to restart now? (y/n): " response
case "$response" in
    [Yy]*)
        echo -e "${GREEN}Restarting...${NC}"
        sudo reboot
        ;;
    *)
        echo -e "${GREEN}Restart skipped. Remember to log out/restart to use DWM.${NC}"
        ;;
esac