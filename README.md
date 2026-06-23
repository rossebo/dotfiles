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
