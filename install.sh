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

conflicts=$(stow --target="$TARGET_DIR" --no-folding --simulate . 2>&1 || true)
if printf '%s\n' "$conflicts" | grep -q 'existing target is neither a link nor a directory'; then
  echo "$conflicts"
  echo
  echo "Stow found conflicts. Back up or move those files, then rerun." >&2
  exit 1
fi

if [ "$DRY_RUN" -eq 1 ]; then
  stow --target="$TARGET_DIR" --no-folding --simulate --verbose .
else
  stow --target="$TARGET_DIR" --no-folding --verbose .
fi

echo
echo "Secrets are not managed by this repo. Provision SSH keys, GitHub auth, npm tokens, Docker auth, and opencode tokens separately."
