#!/usr/bin/env bash
# ---
# file: "install.sh"
# purpose: "Install this zsh setup from GitHub in one command."
# shell: "bash"
# ---

set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/malh/zsh-dotfiles-macos.git}"
BRANCH="${BRANCH:-main}"
TARGET_DIR="${TARGET_DIR:-$HOME/.local/src/zsh-dotfiles}"

_c="\033[1;34m" _w="\033[1;33m" _r="\033[0m"
log()  { printf "${_c}%-12s${_r} %s\n" "[$1]" "$2"; }
warn() { printf "${_w}%-12s${_r} %s\n" "[$1]" "$2"; }

if [[ -z "$REPO_URL" ]]; then
  echo "REPO_URL is required."
  echo "Example:"
  echo "  REPO_URL='https://github.com/<you>/<repo>.git' bash install.sh"
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "git is required but not installed."
  exit 1
fi

mkdir -p "$(dirname "$TARGET_DIR")"

if [[ -d "$TARGET_DIR/.git" ]]; then
  log "fetch" "Updating repo..."
  git -C "$TARGET_DIR" fetch origin -q 2>&1 | grep -v '^remote:' || true
  git -C "$TARGET_DIR" checkout "$BRANCH" -q 2>/dev/null
  git -C "$TARGET_DIR" pull --ff-only origin "$BRANCH" -q 2>/dev/null || {
    warn "fetch" "Fast-forward not possible — resetting to origin/$BRANCH"
    git -C "$TARGET_DIR" reset --hard "origin/$BRANCH" -q 2>/dev/null
  }
else
  log "clone" "Cloning into $TARGET_DIR..."
  git clone --branch "$BRANCH" --depth 1 -q "$REPO_URL" "$TARGET_DIR" 2>/dev/null
fi

log "bootstrap" "Running bootstrap..."
printf '\n'
bash "$TARGET_DIR/bootstrap.sh"
