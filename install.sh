#!/usr/bin/env bash
# Dotfiles bootstrap script.
#
# Run automatically by GitHub Codespaces when "Automatically install dotfiles"
# is enabled (Settings > Codespaces > Dotfiles). Safe to re-run manually.
#
# Installs the tools referenced by these dotfiles (.zshrc, .tmux.conf), sets
# zsh as the default shell, and symlinks everything into $HOME with GNU Stow.
# Downloads are verified in-line (sha256) instead of piping curl into a shell.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

echo "==> Bootstrapping dotfiles from $DOTFILES_DIR"

SUDO=""
if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
fi

mkdir -p "$HOME/.local/bin"

# --- Install packages available via apt -------------------------------------
if command -v apt-get >/dev/null 2>&1; then
  echo "==> Installing packages via apt-get"
  $SUDO apt-get update -y

  # Required by these dotfiles / this script.
  $SUDO apt-get install -y zsh git curl ca-certificates stow tmux

  # Referenced in .zshrc but optional: install what's available in this
  # Ubuntu release and skip the rest instead of failing the whole script.
  for pkg in fzf bat fd-find eza zoxide; do
    $SUDO apt-get install -y "$pkg" || echo "==> Skipping unavailable apt package: $pkg"
  done
else
  echo "==> apt-get not found, skipping apt package installation."
fi

# Ubuntu's apt packages install these under different binary names; expose
# the names .zshrc expects.
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi
if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
  ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
fi

clone_if_missing() {
  local repo="$1" dest="$2"
  if [ ! -d "$dest" ]; then
    echo "==> Cloning $repo -> $dest"
    git clone --depth=1 "https://github.com/${repo}.git" "$dest"
  fi
}

# --- oh-my-zsh + plugins/theme (via git clone, not curl|sh) -----------------
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
export ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"

clone_if_missing "ohmyzsh/ohmyzsh" "$ZSH"
clone_if_missing "zsh-users/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_if_missing "zsh-users/zsh-syntax-highlighting" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
clone_if_missing "romkatv/powerlevel10k" "$ZSH_CUSTOM/themes/powerlevel10k"

# --- tmux plugin manager (tpm), required by .tmux.conf ----------------------
clone_if_missing "tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm"

# --- starship prompt (verified download, no curl|sh) ------------------------
if ! command -v starship >/dev/null 2>&1; then
  echo "==> Installing starship"
  ARCH="$(uname -m)"
  case "$ARCH" in
    x86_64) STARSHIP_ASSET="starship-x86_64-unknown-linux-gnu.tar.gz" ;;
    aarch64) STARSHIP_ASSET="starship-aarch64-unknown-linux-musl.tar.gz" ;;
    *) STARSHIP_ASSET="" ;;
  esac
  if [ -n "$STARSHIP_ASSET" ]; then
    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT
    BASE_URL="https://github.com/starship/starship/releases/latest/download"
    curl -fsSL "$BASE_URL/${STARSHIP_ASSET}" -o "$TMP_DIR/starship.tar.gz"
    curl -fsSL "$BASE_URL/${STARSHIP_ASSET}.sha256" -o "$TMP_DIR/starship.tar.gz.sha256"
    (cd "$TMP_DIR" && sha256sum -c starship.tar.gz.sha256)
    tar -xzf "$TMP_DIR/starship.tar.gz" -C "$TMP_DIR"
    install -m 0755 "$TMP_DIR/starship" "$HOME/.local/bin/starship"
    rm -rf "$TMP_DIR"
    trap - EXIT
  else
    echo "==> Unsupported architecture ($ARCH) for starship, skipping."
  fi
else
  echo "==> starship already installed"
fi

# --- GitHub Copilot CLI ------------------------------------------------------
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

# --- Symlink dotfiles with GNU Stow ------------------------------------------
if command -v stow >/dev/null 2>&1; then
  echo "==> Stowing dotfiles into $HOME"
  stow --target="$HOME" --restow . || echo "==> stow reported conflicts; resolve manually with 'stow -v .'"
else
  echo "==> GNU Stow not found, skipping symlink step."
fi

# --- Set zsh as the default shell -------------------------------------------
ZSH_BIN="$(command -v zsh || true)"
if [ -n "$ZSH_BIN" ] && [ "${SHELL:-}" != "$ZSH_BIN" ]; then
  echo "==> Setting zsh as the default shell"
  grep -qxF "$ZSH_BIN" /etc/shells 2>/dev/null || echo "$ZSH_BIN" | $SUDO tee -a /etc/shells >/dev/null
  # Use usermod instead of chsh: chsh authenticates via PAM against the
  # *target* user's own password, which fails non-interactively (no TTY
  # during dotfiles install, and Codespaces users typically have no
  # password set at all). usermod edits /etc/passwd directly as root and
  # needs no interactive auth.
  if $SUDO usermod -s "$ZSH_BIN" "$(whoami)"; then
    echo "==> Default shell set to $ZSH_BIN (restart your terminal/session for it to take effect)"
  else
    echo "==> Could not set default shell automatically; run 'sudo usermod -s $ZSH_BIN \$(whoami)' manually."
  fi
fi

echo "==> Dotfiles bootstrap complete. Open a new terminal (or restart the Codespace shell) to use zsh."
