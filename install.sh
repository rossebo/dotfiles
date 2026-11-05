#!/usr/bin/env bash
# Dotfiles bootstrap script.
#
# Run automatically by GitHub Codespaces when "Automatically install dotfiles"
# is enabled (Settings > Codespaces > Dotfiles). Safe to re-run manually.
#
# Installs the tools referenced by these dotfiles (.zshrc, .tmux.conf), sets
# zsh as the default shell, and symlinks everything into $HOME with GNU Stow.
# Downloads are verified in-line (sha256) instead of piping curl into a shell.
#
# IMPORTANT: critical steps (stow, default shell, exec-zsh) run first and use
# 'set +e' locally where needed, so a failure in any single *optional* step
# below (oh-my-zsh, starship, tpm, Copilot CLI) can never abort the script
# before the critical steps have run. See postmortem in git history: an
# earlier version used 'set -e' for the whole script, so a starship
# checksum-format bug silently skipped stow/shell setup entirely.
set -uo pipefail

# Guarantee this script never blocks waiting on stdin/interactive input, no
# matter what runs inside it. Codespace/container creation has no TTY, so any
# accidental prompt (debconf, git credential prompt, a tool's own interactive
# y/n) would hang the whole bootstrap forever with no visible error. We've
# seen exactly this class of bug hang a codespace via another tool's
# interactive prompt, so apply the same defense here even though this script
# doesn't currently trigger one.
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true
export GIT_TERMINAL_PROMPT=0

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
  $SUDO apt-get update -y </dev/null

  # Required by these dotfiles / this script.
  $SUDO apt-get install -y zsh git curl ca-certificates stow tmux jq </dev/null

  # Referenced in .zshrc but optional: install what's available in this
  # Ubuntu release and skip the rest instead of failing the whole script.
  # ncurses-term ships the xterm-kitty terminfo (needed when SSHing in from Kitty).
  for pkg in fzf bat fd-find eza zoxide ncurses-term; do
    $SUDO apt-get install -y "$pkg" </dev/null || echo "==> Skipping unavailable apt package: $pkg"
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

# =============================================================================
# CRITICAL SECTION: must always run, even if something above failed.
# =============================================================================

# --- Symlink dotfiles with GNU Stow ------------------------------------------
if command -v stow >/dev/null 2>&1; then
  # The Codespaces base image (or earlier steps, e.g. apt installing zsh)
  # can create real (non-symlink) files at some of our stow targets, e.g.
  # ~/.zshrc. Stow refuses to overwrite a real file and aborts stowing
  # *everything* if even one target conflicts. Force-remove any conflicting
  # real file/dir at each top-level package entry first so stow can proceed
  # (no backup: per-repo decision, the dotfiles repo's version always wins).
  for entry in "$DOTFILES_DIR"/.[!.]* "$DOTFILES_DIR"/*; do
    [ -e "$entry" ] || continue
    name="$(basename "$entry")"
    case "$name" in
      .git|.gitignore|.stow-local-ignore|README.md|install.sh|.DS_Store|skills) continue ;;
    esac
    target="$HOME/$name"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "==> Removing pre-existing $target so it can be replaced by a symlink"
      rm -rf "$target"
    fi
  done

  echo "==> Stowing dotfiles into $HOME"
  stow --target="$HOME" --restow . || echo "==> stow reported conflicts; resolve manually with 'stow -v .'"
else
  echo "==> GNU Stow not found, skipping symlink step."
fi

# --- Link agent skills for GitHub Copilot CLI --------------------------------
# Skills live in $DOTFILES_DIR/skills/<name>/SKILL.md. They are linked one by
# one into ~/.copilot/skills instead of stowed, because ~/.copilot also holds
# Copilot's own state/auth and must stay a real directory (stow would fold it
# into a symlink to this repo, and the cleanup loop above would delete it).
if [ -d "$DOTFILES_DIR/skills" ]; then
  mkdir -p "$HOME/.copilot/skills"
  for skill in "$DOTFILES_DIR"/skills/*/; do
    [ -f "${skill}SKILL.md" ] || continue
    ln -sfn "${skill%/}" "$HOME/.copilot/skills/$(basename "$skill")"
    echo "==> Linked skill $(basename "$skill")"
  done
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

# --- Make interactive bash sessions exec into zsh ---------------------------
# GitHub Codespaces terminals (both the VS Code integrated terminal and
# 'gh codespace ssh') always start 'bash' for the session, regardless of the
# /etc/passwd shell field set above by usermod/chsh. The standard workaround
# is to have bash exec into zsh for interactive sessions.
if [ -n "$ZSH_BIN" ]; then
  BASHRC="$HOME/.bashrc"
  MARKER="# >>> dotfiles: exec zsh for interactive sessions >>>"
  if [ ! -f "$BASHRC" ] || ! grep -qF "$MARKER" "$BASHRC" 2>/dev/null; then
    echo "==> Adding exec-zsh snippet to $BASHRC"
    {
      echo ""
      echo "$MARKER"
      echo "if [ -t 1 ] && [ -z \"\${DOTFILES_ZSH_EXECED:-}\" ] && command -v zsh >/dev/null 2>&1; then"
      echo "  export DOTFILES_ZSH_EXECED=1"
      echo "  exec zsh"
      echo "fi"
      echo "# <<< dotfiles: exec zsh for interactive sessions <<<"
    } >> "$BASHRC"
  fi
fi

# =============================================================================
# OPTIONAL / NICE-TO-HAVE SECTION: each step is independently fault-tolerant,
# so one failing (e.g. a GitHub release asset changing format) can't affect
# the critical section above, which always runs first.
# =============================================================================

clone_if_missing() {
  local repo="$1" dest="$2"
  if [ ! -d "$dest" ]; then
    echo "==> Cloning $repo -> $dest"
    git clone --depth=1 "https://github.com/${repo}.git" "$dest" </dev/null || echo "==> Failed to clone $repo, skipping."
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
# Install the plugins listed in .tmux.conf without needing prefix + I
"$HOME/.tmux/plugins/tpm/bin/install_plugins" || echo "==> tpm plugin install failed (run prefix + I in tmux)"

# --- starship prompt (verified download, no curl|sh) ------------------------
install_starship() {
  command -v starship >/dev/null 2>&1 && { echo "==> starship already installed"; return 0; }

  echo "==> Installing starship"
  local arch asset base_url tmp_dir
  arch="$(uname -m)"
  case "$arch" in
    x86_64) asset="starship-x86_64-unknown-linux-gnu.tar.gz" ;;
    aarch64) asset="starship-aarch64-unknown-linux-musl.tar.gz" ;;
    *) echo "==> Unsupported architecture ($arch) for starship, skipping."; return 0 ;;
  esac

  tmp_dir="$(mktemp -d)"
  base_url="https://github.com/starship/starship/releases/latest/download"

  curl -fsSL "$base_url/${asset}" -o "$tmp_dir/starship.tar.gz" || { echo "==> Failed to download starship, skipping."; rm -rf "$tmp_dir"; return 0; }
  curl -fsSL "$base_url/${asset}.sha256" -o "$tmp_dir/starship.tar.gz.sha256" || { echo "==> Failed to download starship checksum, skipping."; rm -rf "$tmp_dir"; return 0; }

  # starship's .sha256 asset contains only the raw hex digest (no filename),
  # not the "<hash>  <filename>" line format 'sha256sum -c' requires. Build
  # that line ourselves instead of feeding the file to sha256sum -c directly.
  local expected actual
  expected="$(tr -d '[:space:]' < "$tmp_dir/starship.tar.gz.sha256")"
  actual="$(sha256sum "$tmp_dir/starship.tar.gz" | awk '{print $1}')"
  if [ "$expected" != "$actual" ]; then
    echo "==> starship checksum mismatch (expected $expected, got $actual), skipping install."
    rm -rf "$tmp_dir"
    return 0
  fi

  tar -xzf "$tmp_dir/starship.tar.gz" -C "$tmp_dir" && install -m 0755 "$tmp_dir/starship" "$HOME/.local/bin/starship"
  rm -rf "$tmp_dir"
}
install_starship

# --- Neovim tooling (nvim >= 0.12, lazygit, tree-sitter CLI) ----------------
# nvim config uses vim.pack (needs 0.12+), snacks.lazygit, and nvim-treesitter
# (main branch) which compiles parsers with the tree-sitter CLI. Downloads are
# verified against the sha256 digest GitHub publishes for each release asset.

# Prints "<download_url> <sha256>" for the first asset of the latest release
# of $1 whose name matches the jq regex $2.
gh_release_asset() {
  # Authenticate when a token is available; unauthenticated API calls get rate limited (403).
  curl -fsSL ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} "https://api.github.com/repos/$1/releases/latest" \
    | jq -r --arg re "$2" '[.assets[] | select(.name | test($re))][0] | "\(.browser_download_url) \(.digest | sub("^sha256:"; ""))"'
}

# Downloads asset $2 (jq regex) of repo $1 into $3 and verifies its checksum.
# Echoes the downloaded file path.
gh_release_download() {
  local info url expected
  info="$(gh_release_asset "$1" "$2")" || return 1
  url="${info% *}"
  expected="${info##* }"
  case "$url" in https://*) ;; *) return 1 ;; esac
  [ -n "$expected" ] || return 1
  curl -fsSL "$url" -o "$3/$(basename "$url")" || return 1
  [ "$(sha256sum "$3/$(basename "$url")" | awk '{print $1}')" = "$expected" ] || { echo "==> checksum mismatch for $url" >&2; return 1; }
  echo "$3/$(basename "$url")"
}

install_neovim_tools() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "==> jq not found, skipping nvim/lazygit/tree-sitter install."
    return 0
  fi

  local nvim_asset lazygit_re ts_asset
  case "$(uname -m)" in
    x86_64) nvim_asset="^nvim-linux-x86_64\\.tar\\.gz$"; lazygit_re="_linux_x86_64\\.tar\\.gz$"; ts_asset="^tree-sitter-linux-x64\\.gz$" ;;
    aarch64) nvim_asset="^nvim-linux-arm64\\.tar\\.gz$"; lazygit_re="_linux_arm64\\.tar\\.gz$"; ts_asset="^tree-sitter-linux-arm64\\.gz$" ;;
    *) echo "==> Unsupported architecture ($(uname -m)) for nvim tooling, skipping."; return 0 ;;
  esac

  local tmp_dir file
  tmp_dir="$(mktemp -d)"

  local nvim_minor=""
  command -v nvim >/dev/null 2>&1 && nvim_minor="$(nvim --version | sed -n '1s/^NVIM v0\.\([0-9]*\).*/\1/p')"
  if [ -n "$nvim_minor" ] && [ "$nvim_minor" -ge 12 ]; then
    echo "==> nvim already installed ($(nvim --version | head -1))"
  else
    echo "==> Installing neovim"
    if file="$(gh_release_download neovim/neovim "$nvim_asset" "$tmp_dir")"; then
      rm -rf "$HOME/.local/nvim" && mkdir -p "$HOME/.local/nvim" \
        && tar -xzf "$file" -C "$HOME/.local/nvim" --strip-components=1 \
        && ln -sf "$HOME/.local/nvim/bin/nvim" "$HOME/.local/bin/nvim" \
        || echo "==> Failed to install neovim, skipping."
    else
      echo "==> Failed to download neovim, skipping."
    fi
  fi

  if command -v lazygit >/dev/null 2>&1; then
    echo "==> lazygit already installed"
  else
    echo "==> Installing lazygit"
    if file="$(gh_release_download jesseduffield/lazygit "$lazygit_re" "$tmp_dir")"; then
      tar -xzf "$file" -C "$tmp_dir" lazygit && install -m 0755 "$tmp_dir/lazygit" "$HOME/.local/bin/lazygit" \
        || echo "==> Failed to install lazygit, skipping."
    else
      echo "==> Failed to download lazygit, skipping."
    fi
  fi

  if command -v tree-sitter >/dev/null 2>&1; then
    echo "==> tree-sitter CLI already installed"
  else
    echo "==> Installing tree-sitter CLI"
    if file="$(gh_release_download tree-sitter/tree-sitter "$ts_asset" "$tmp_dir")"; then
      gunzip -c "$file" > "$tmp_dir/tree-sitter" && install -m 0755 "$tmp_dir/tree-sitter" "$HOME/.local/bin/tree-sitter" \
        || echo "==> Failed to install tree-sitter CLI, skipping."
    else
      echo "==> Failed to download tree-sitter CLI, skipping."
    fi
  fi

  rm -rf "$tmp_dir"
}
install_neovim_tools

# --- GitHub Copilot CLI ------------------------------------------------------
if command -v npm >/dev/null 2>&1; then
  if ! command -v copilot >/dev/null 2>&1; then
    echo "==> Installing GitHub Copilot CLI (@github/copilot) via npm"
    npm install -g @github/copilot </dev/null || echo "==> Failed to install GitHub Copilot CLI, skipping."
  else
    echo "==> GitHub Copilot CLI already installed ($(copilot --version 2>/dev/null || echo 'unknown version'))"
  fi
else
  echo "==> npm not found, skipping GitHub Copilot CLI install."
fi

echo "==> Dotfiles bootstrap complete. Open a new terminal (or restart the Codespace shell) to use zsh."
