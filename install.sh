#!/usr/bin/env bash
# ---
# file: "install.sh"
# purpose: "Install this zsh setup from GitHub in one command."
# shell: "bash"
# ---

set -euo pipefail

REPO_URL="${REPO_URL:-}"
BRANCH="${BRANCH:-main}"
TARGET_DIR="${TARGET_DIR:-$HOME/.local/src/zsh-dotfiles}"

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
  git -C "$TARGET_DIR" fetch origin
  git -C "$TARGET_DIR" checkout "$BRANCH"
  git -C "$TARGET_DIR" pull --ff-only origin "$BRANCH"
else
  git clone --branch "$BRANCH" --depth 1 "$REPO_URL" "$TARGET_DIR"
fi

bash "$TARGET_DIR/bootstrap.sh"
