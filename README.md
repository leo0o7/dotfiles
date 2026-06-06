# Dotfiles

Personal macOS dotfiles managed with GNU Stow.

## Install

Install Homebrew dependencies and symlink configs:

```sh
./install.sh --brew
```

Preview Stow actions first:

```sh
./install.sh --dry-run
```

## Layout

This repository mimics `$HOME`. Stow links files from this repo into the real home directory.

Examples:

```text
.zshrc -> ~/.zshrc
.config/nvim -> ~/.config/nvim
.config/lazygit/config.yml -> ~/.config/lazygit/config.yml
```

## Secrets

Secrets are intentionally excluded. Do not commit SSH keys, npm tokens, Docker auth, GitHub CLI hosts, opencode token files, or local session databases.

Provision these separately after install.
