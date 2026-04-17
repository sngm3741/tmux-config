#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# OS判定
detect_os() {
  case "$(uname -s)" in
    Darwin) echo "mac" ;;
    Linux)
      if grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl"
      else
        echo "linux"
      fi
      ;;
    MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
    *) echo "unknown" ;;
  esac
}

OS=$(detect_os)
echo "OS: $OS"

# Windowsネイティブはtmux非対応
if [ "$OS" = "windows" ]; then
  echo "Windows native is not supported. Use WSL instead."
  exit 1
fi

# シンボリックリンク作成
TMUX_CONF="$SCRIPT_DIR/.tmux.conf"
TARGET="$HOME/.tmux.conf"

if [ -L "$TARGET" ]; then
  echo "Symlink already exists: $TARGET"
elif [ -f "$TARGET" ]; then
  echo "Backing up existing $TARGET to $TARGET.bak"
  mv "$TARGET" "$TARGET.bak"
  ln -s "$TMUX_CONF" "$TARGET"
  echo "Symlink created: $TARGET -> $TMUX_CONF"
else
  ln -s "$TMUX_CONF" "$TARGET"
  echo "Symlink created: $TARGET -> $TMUX_CONF"
fi

# TPMインストール
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  echo "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
  echo "TPM installed."
else
  echo "TPM already installed."
fi

echo "Done. Run 'tmux source ~/.tmux.conf' and then prefix + I to install plugins."
