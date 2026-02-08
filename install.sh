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

_b="\033[1m" _c="\033[1;34m" _d="\033[2m" _w="\033[1;33m" _r="\033[0m"
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

printf "\n  ${_b}zsh-dotfiles-macos${_r}\n"
printf "  ${_d}repo:${_r}   %s\n" "$REPO_URL"
printf "  ${_d}branch:${_r} %s\n" "$BRANCH"
printf "  ${_d}target:${_r} %s\n\n" "$TARGET_DIR"

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
  log "clone" "Cloning repo..."
  git clone --branch "$BRANCH" --depth 1 -q "$REPO_URL" "$TARGET_DIR" 2>/dev/null
fi

printf '\n'
log "bootstrap" "Running bootstrap..."
printf '\n'
bash "$TARGET_DIR/bootstrap.sh"
