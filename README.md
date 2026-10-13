# dotfiles

Using GNU Stow to manage config files

Sketchybar
TODO: Add install prompt

NeoVim
TODO: Add install prompt

SKHD
TODO: Add install prompt

Yabai
TODO: Add install prompt

zsh
TODO: Install prompt


Add this to .gitconfig
[alias]
	go-default = "!f() { default=$(git symbolic-ref refs/remotes/origin/HEAD | sed \"s|^refs/remotes/origin/||\"); git switch \"$default\"; }; f"
	go = !git switch $(git symbolic-ref refs/remotes/origin/HEAD | sed \"s|^refs/remotes/origin/||\")

## Codespaces from Kitty

`install.sh` installs `ncurses-term` (provides the `xterm-kitty` terminfo), and `.zshrc`
falls back to `TERM=xterm-256color` if it's still missing, so input/`clear` don't break.

Workflow: one Kitty tab for the Codespace, other tabs for local work (no nested tmux).
In the Codespace tab run `cs`, which SSHes in and attaches to a persistent tmux session
(`main`), creating it if needed. tmux runs only inside the Codespace, with the usual `C-q` prefix.
