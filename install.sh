#!/usr/bin/env sh
set -eu

DOTFILES_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
TARGET_DIR=${TARGET_DIR:-$HOME}
BACKUP_DIR=${BACKUP_DIR:-$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)}
DRY_RUN=0
RUN_BREW=0

usage() {
  cat <<'EOF'
Usage: ./install.sh [--dry-run] [--brew]

Options:
  --dry-run  Show planned backups and Stow actions without changing files.
  --brew     Run brew bundle before stowing.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --brew) RUN_BREW=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
  shift
done

if ! command -v stow >/dev/null 2>&1; then
  echo "stow is not installed. Run: brew install stow" >&2
  exit 1
fi

if [ "$RUN_BREW" -eq 1 ]; then
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "Would run: brew bundle --file '$DOTFILES_DIR/Brewfile'"
  else
    brew bundle --file "$DOTFILES_DIR/Brewfile"
  fi
fi

cd "$DOTFILES_DIR"

backup_existing_targets() {
  git ls-files | while IFS= read -r path; do
    case "$path" in
      .gitignore|.stow-local-ignore|Brewfile|install.sh|README.md) continue ;;
    esac

    target=$TARGET_DIR/$path
    backup=$BACKUP_DIR/$path

    if [ -e "$target" ] && [ ! -L "$target" ]; then
      if [ "$DRY_RUN" -eq 1 ]; then
        echo "Would back up: $target -> $backup"
      else
        mkdir -p "$(dirname -- "$backup")"
        mv "$target" "$backup"
      fi
    fi
  done
}

if [ "$DRY_RUN" -eq 1 ]; then
  backup_existing_targets
  echo
  echo "Would run: stow --target='$TARGET_DIR' --no-folding --verbose ."
else
  backup_existing_targets
  stow --target="$TARGET_DIR" --no-folding --verbose .
fi

echo
echo "Secrets are not managed by this repo. Provision SSH keys, GitHub auth, npm tokens, Docker auth, and opencode tokens separately."
