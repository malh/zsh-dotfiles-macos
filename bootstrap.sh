#!/usr/bin/env bash
# ---
# file: "bootstrap.sh"
# purpose: "Idempotently install and sync the zsh setup into ~/.config/zsh."
# shell: "bash"
# ---

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_ZSH_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
TARGET_ZSHENV="$HOME/.zshenv"
BACKUP_BASE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/bootstrap-backups"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_BASE/$TIMESTAMP"
MERGE_REPORT="$BACKUP_DIR/merge-suggestions.md"
BACKUP_INDEX_DIR="$TARGET_ZSH_DIR/backups.d"
BACKUP_CREATED=0

_c="\033[1;34m" _g="\033[1;32m" _d="\033[2m" _r="\033[0m"
log() { printf "${_c}%-12s${_r} %s\n" "[$1]" "$2"; }

ensure_brew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  log "brew" "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

install_packages() {
  if [[ -f "$ROOT_DIR/Brewfile" ]]; then
    log "brew" "Installing packages from Brewfile..."
    brew bundle --file "$ROOT_DIR/Brewfile" --quiet
    return
  fi

  local pkg missing=()
  for pkg in antidote starship neovim zsh-completions fzf; do
    if ! brew list "$pkg" &>/dev/null; then
      missing+=("$pkg")
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    log "brew" "Installing ${missing[*]}..."
    brew install --quiet "${missing[@]}"
  else
    log "brew" "All packages already installed."
  fi
}

ensure_dirs() {
  mkdir -p \
    "$TARGET_ZSH_DIR/conf.d" \
    "$TARGET_ZSH_DIR/antidote" \
    "$TARGET_ZSH_DIR/starship" \
    "${XDG_CACHE_HOME:-$HOME/.cache}/zsh" \
    "${XDG_STATE_HOME:-$HOME/.local/state}/zsh" \
    "$BACKUP_BASE"
}

install_repo_files() {
  log "sync" "Syncing config to $TARGET_ZSH_DIR..."
  local changes
  changes="$(rsync -ai --delete \
    --exclude ".git" \
    --exclude ".gitignore" \
    --exclude "README.md" \
    --exclude "plan.md" \
    --exclude "bootstrap.sh" \
    --exclude ".zshenv.example" \
    "$ROOT_DIR/" "$TARGET_ZSH_DIR/" 2>&1 \
    | grep '^>f' | sed 's/^[^ ]* //' || true)"

  if [[ -n "$changes" ]]; then
    while IFS= read -r file; do
      printf "             ${_d}updated${_r}  %s\n" "$file"
    done <<< "$changes"
  else
    printf "             ${_d}no changes${_r}\n"
  fi
}

install_zshenv() {
  cp "$ROOT_DIR/.zshenv.example" "$TARGET_ZSHENV"
}

backup_existing_config() {
  local legacy_file

  mkdir -p "$BACKUP_DIR"

  if [[ -f "$TARGET_ZSHENV" ]]; then
    mkdir -p "$BACKUP_DIR/home"
    cp -a "$TARGET_ZSHENV" "$BACKUP_DIR/home/.zshenv"
    BACKUP_CREATED=1
  fi

  if [[ -d "$TARGET_ZSH_DIR" ]]; then
    mkdir -p "$BACKUP_DIR/config"
    rsync -a "$TARGET_ZSH_DIR/" "$BACKUP_DIR/config/zsh/"
    BACKUP_CREATED=1
  fi

  for legacy_file in "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.zlogin" "$HOME/.zlogout"; do
    if [[ -f "$legacy_file" ]]; then
      mkdir -p "$BACKUP_DIR/home"
      cp -a "$legacy_file" "$BACKUP_DIR/home/"
      BACKUP_CREATED=1
    fi
  done

  if [[ "$BACKUP_CREATED" -eq 0 ]]; then
    rmdir "$BACKUP_DIR" 2>/dev/null || true
  else
    log "backup" "Saved existing config."
  fi
}

collect_merge_lines() {
  local heading="$1"
  local pattern="$2"
  shift 2
  local file
  local has_matches=0

  printf '## %s\n\n' "$heading" >> "$MERGE_REPORT"

  for file in "$@"; do
    if [[ -f "$file" ]]; then
      local matches
      matches="$(grep -nE "$pattern" "$file" || true)"
      if [[ -n "$matches" ]]; then
        has_matches=1
        printf '### `%s`\n\n' "$file" >> "$MERGE_REPORT"
        printf '```zsh\n%s\n```\n\n' "$matches" >> "$MERGE_REPORT"
      fi
    fi
  done

  if [[ "$has_matches" -eq 0 ]]; then
    printf '_No matches found._\n\n' >> "$MERGE_REPORT"
  fi
}

generate_merge_suggestions() {
  local files=()
  local file

  if [[ "$BACKUP_CREATED" -eq 0 ]]; then
    return
  fi

  if [[ -d "$BACKUP_DIR/home" ]]; then
    while IFS= read -r -d '' file; do
      files+=("$file")
    done < <(find "$BACKUP_DIR/home" -maxdepth 1 -type f -print0)
  fi

  if [[ -d "$BACKUP_DIR/config/zsh" ]]; then
    while IFS= read -r -d '' file; do
      files+=("$file")
    done < <(find "$BACKUP_DIR/config/zsh" -maxdepth 2 -type f -name '*.zsh' -print0)
  fi

  {
    printf '# Merge Suggestions\n\n'
    printf 'Backup source: `%s`\n\n' "$BACKUP_DIR"
    printf 'Use this report to move prior customizations into the new module layout:\n\n'
    printf '%s\n' '- `conf.d/00-env.zsh`: general exports and editor defaults'
    printf '%s\n' '- `conf.d/05-secrets.zsh`: private tokens, keys, credentials'
    printf '%s\n' '- `conf.d/10-options.zsh`: `setopt`, history settings'
    printf '%s\n' '- `conf.d/20-path.zsh`: `PATH`, `path`, `fpath`'
    printf '%s\n' '- `conf.d/30-plugins.zsh` + `antidote/plugins.txt`: plugin/completion config'
    printf '%s\n' '- `conf.d/50-aliases.zsh`: aliases and shell functions'
    printf '%s\n' '- `conf.d/70-tools.zsh`: tool init lines (`eval`, `source`, hook setup)'
    printf '%s\n\n' '- `conf.d/99-local.zsh`: machine-specific overrides'
  } > "$MERGE_REPORT"

  collect_merge_lines "Environment Exports -> 00-env or 05-secrets/99-local" \
    '^[[:space:]]*export[[:space:]]+[A-Za-z_][A-Za-z0-9_]*=' \
    "${files[@]}"

  collect_merge_lines "Shell Options and History -> 10-options" \
    '^[[:space:]]*(setopt|unsetopt|HISTSIZE=|SAVEHIST=)' \
    "${files[@]}"

  collect_merge_lines "PATH/fpath Setup -> 20-path" \
    '(^[[:space:]]*PATH=|^[[:space:]]*path=|^[[:space:]]*fpath=|[[:space:]]PATH[[:space:]]*=)' \
    "${files[@]}"

  collect_merge_lines "Plugins and Completion -> 30-plugins / antidote/plugins.txt" \
    '(antidote|zinit|zplug|oh-my-zsh|compinit|fpath)' \
    "${files[@]}"

  collect_merge_lines "Aliases and Functions -> 50-aliases or 99-local" \
    '^[[:space:]]*(alias[[:space:]]+[A-Za-z0-9_.-]+=|[A-Za-z_][A-Za-z0-9_]*[[:space:]]*\(\)[[:space:]]*\{)' \
    "${files[@]}"

  collect_merge_lines "Tool Initialization -> 70-tools" \
    '^[[:space:]]*(eval[[:space:]]|source[[:space:]]|\. [^#])' \
    "${files[@]}"
}

ensure_local_files() {
  if [[ ! -f "$TARGET_ZSH_DIR/conf.d/05-secrets.zsh" ]]; then
    cp "$TARGET_ZSH_DIR/conf.d/05-secrets.example.zsh" "$TARGET_ZSH_DIR/conf.d/05-secrets.zsh"
  fi

  if [[ ! -f "$TARGET_ZSH_DIR/conf.d/99-local.zsh" ]]; then
    cp "$TARGET_ZSH_DIR/conf.d/99-local.example.zsh" "$TARGET_ZSH_DIR/conf.d/99-local.zsh"
  fi

  chmod 600 "$TARGET_ZSH_DIR/conf.d/05-secrets.zsh"
}

build_antidote_bundle() {
  local plugins_file="$TARGET_ZSH_DIR/antidote/plugins.txt"
  local bundle_file="$TARGET_ZSH_DIR/antidote/.zsh_plugins.zsh"
  local antidote_zsh="${HOMEBREW_PREFIX:-/opt/homebrew}/opt/antidote/share/antidote/antidote.zsh"

  if [[ -r "$antidote_zsh" ]] && [[ -r "$plugins_file" ]]; then
    log "plugins" "Bundling antidote plugins..."
    zsh -c "source '$antidote_zsh' && antidote bundle < '$plugins_file' > '$bundle_file'" 2>&1 \
      | grep -v '^#' || true
  fi
}

install_fzf_extras() {
  if command -v brew >/dev/null 2>&1; then
    local fzf_install
    fzf_install="$(brew --prefix)/opt/fzf/install"
    if [[ -x "$fzf_install" ]]; then
      log "fzf" "Installing key-bindings and completions..."
      "$fzf_install" --no-bash --no-fish --key-bindings --completion --no-update-rc >/dev/null 2>&1 || true
    fi
  fi
}

expose_backup_in_zdotdir() {
  if [[ "$BACKUP_CREATED" -ne 1 ]]; then
    return
  fi

  mkdir -p "$BACKUP_INDEX_DIR"
  ln -sfn "$BACKUP_DIR" "$BACKUP_INDEX_DIR/$TIMESTAMP"
  ln -sfn "$BACKUP_INDEX_DIR/$TIMESTAMP" "$BACKUP_INDEX_DIR/latest"
}

validate() {
  log "check" "Validating syntax..."
  ZDOTDIR="$TARGET_ZSH_DIR" zsh -n "$TARGET_ZSH_DIR/.zshrc" "$TARGET_ZSH_DIR/conf.d/"*.zsh
}

print_summary() {
  local tilde_zsh="${TARGET_ZSH_DIR/#$HOME/~}"

  printf '\n'
  printf "  ${_c}Installed layout:${_r}\n"
  printf "  ~/.zshenv                        ${_d}-> sets ZDOTDIR${_r}\n"
  printf "  %s/\n" "$tilde_zsh"
  printf "    .zshrc                         ${_d}-> module dispatcher${_r}\n"
  printf "    conf.d/\n"
  printf "      00-env.zsh                   ${_d}-> env vars, XDG${_r}\n"
  printf "      05-secrets.zsh               ${_d}-> private tokens${_r}\n"
  printf "      10-options.zsh               ${_d}-> setopt, history${_r}\n"
  printf "      20-path.zsh                  ${_d}-> PATH, fpath${_r}\n"
  printf "      30-plugins.zsh               ${_d}-> antidote + compinit${_r}\n"
  printf "      50-aliases.zsh               ${_d}-> aliases${_r}\n"
  printf "      70-tools.zsh                 ${_d}-> tool init (fzf, etc)${_r}\n"
  printf "      99-local.zsh                 ${_d}-> machine overrides${_r}\n"
  printf "    antidote/plugins.txt           ${_d}-> plugin list${_r}\n"
  printf "    starship/starship.toml         ${_d}-> prompt theme${_r}\n"

  if [[ "$BACKUP_CREATED" -eq 1 ]]; then
    printf '\n'
    printf "  ${_d}Backup:${_r}     %s\n" "$BACKUP_INDEX_DIR/latest"
    printf "  ${_d}Merge tips:${_r} %s\n" "$MERGE_REPORT"
  fi

  printf "\n  ${_g}Done!${_r} Run: exec zsh -l\n\n"
}

main() {
  backup_existing_config
  ensure_brew
  install_packages
  ensure_dirs
  install_repo_files
  install_zshenv
  ensure_local_files
  build_antidote_bundle
  install_fzf_extras
  generate_merge_suggestions
  expose_backup_in_zdotdir
  validate
  print_summary
}

main "$@"
