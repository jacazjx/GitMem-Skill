#!/usr/bin/env bash
#
# install.sh - Install gitmem scripts
#
# Usage: ./install.sh [options]
#
# Options:
#   --prefix DIR    Install prefix (default: ~/.local)
#   --symlink       Create symlinks instead of copying (default)
#   --copy          Copy files instead of creating symlinks
#   --uninstall     Remove installed files
#

set -e

PREFIX="${HOME}/.local"
USE_SYMLINK=true
UNINSTALL=false

SCRIPTS=(
    "gitmem"
    "gitmem-watch"
    "gitmem-init"
)

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

while [[ $# -gt 0 ]]; do
    case $1 in
        --prefix)
            PREFIX="$2"
            shift 2
            ;;
        --symlink)
            USE_SYMLINK=true
            shift
            ;;
        --copy)
            USE_SYMLINK=false
            shift
            ;;
        --uninstall)
            UNINSTALL=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${PREFIX}/bin"

uninstall() {
    echo -e "${YELLOW}Uninstalling gitmem...${NC}"

    for script in "${SCRIPTS[@]}"; do
        target="${BIN_DIR}/${script}"
        if [[ -L "$target" ]]; then
            rm "$target"
            echo "  Removed symlink: ${target}"
        elif [[ -f "$target" ]]; then
            rm "$target"
            echo "  Removed file: ${target}"
        fi
    done

    echo -e "${GREEN}✓ Uninstall complete${NC}"
}

if $UNINSTALL; then
    uninstall
    exit 0
fi

# Create bin directory if needed
mkdir -p "${BIN_DIR}"

echo -e "${YELLOW}Installing gitmem to ${BIN_DIR}/${NC}"
echo ""

for script in "${SCRIPTS[@]}"; do
    source="${SCRIPT_DIR}/${script}"
    target="${BIN_DIR}/${script}"

    if [[ ! -f "$source" ]]; then
        echo -e "${RED}✗ Source not found: ${source}${NC}"
        continue
    fi

    # Remove existing file/symlink
    if [[ -e "$target" ]] || [[ -L "$target" ]]; then
        rm "$target"
    fi

    if $USE_SYMLINK; then
        ln -s "$source" "$target"
        echo -e "${GREEN}✓ Created symlink: ${target} -> ${source}${NC}"
    else
        cp "$source" "$target"
        chmod +x "$target"
        echo -e "${GREEN}✓ Copied: ${target}${NC}"
    fi
done

echo ""
echo -e "${GREEN}✓ Installation complete!${NC}"
echo ""

# Check if bin dir is in PATH
if [[ ":$PATH:" != *":${BIN_DIR}:"* ]]; then
    echo -e "${YELLOW}Note: ${BIN_DIR} is not in your PATH.${NC}"
    echo ""
    echo "Add this to your ~/.bashrc or ~/.zshrc:"
    echo ""
    echo "    export PATH=\"\${HOME}/.local/bin:\$PATH\""
    echo ""
    echo "Then run: source ~/.bashrc  (or source ~/.zshrc)"
else
    echo "gitmem commands are now available:"
    echo "  gitmem init      - Initialize GitMem"
    echo "  gitmem watch     - Start auto-commit watcher"
    echo "  gitmem --help    - Show all commands"
fi