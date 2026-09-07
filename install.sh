#!/usr/bin/env bash
# Dotfiles bootstrap script.
#
# Run automatically by GitHub Codespaces when "Automatically install dotfiles"
# is enabled (Settings > Codespaces > Dotfiles). Safe to re-run manually.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

echo "==> Bootstrapping dotfiles from $DOTFILES_DIR"

# --- Symlink shell/editor configs with GNU Stow -----------------------------
# Only stow packages that make sense in a (usually Linux) Codespace; skip the
# macOS-only window manager tooling (yabai/skhd/sketchybar) if present.
if command -v stow >/dev/null 2>&1; then
  STOW_TARGETS=()
  for pkg in zsh tmux wezterm; do
    [ -e "$DOTFILES_DIR/.${pkg}" ] || [ -d "$DOTFILES_DIR/.config/${pkg}" ] && STOW_TARGETS+=("$pkg")
  done
  # Fall back to stowing everything except known macOS-only dirs.
  if [ "${#STOW_TARGETS[@]}" -eq 0 ]; then
    stow --target="$HOME" --restow . 2>/dev/null || true
  fi
else
  echo "==> GNU Stow not found, skipping symlink step (files may already be linked by Codespaces)."
fi

# --- Install GitHub Copilot CLI ---------------------------------------------
if command -v npm >/dev/null 2>&1; then
  if ! command -v copilot >/dev/null 2>&1; then
    echo "==> Installing GitHub Copilot CLI (@github/copilot) via npm"
    npm install -g @github/copilot
  else
    echo "==> GitHub Copilot CLI already installed ($(copilot --version 2>/dev/null || echo 'unknown version'))"
  fi
else
  echo "==> npm not found, skipping GitHub Copilot CLI install."
fi

echo "==> Dotfiles bootstrap complete."
