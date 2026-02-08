# ---
# file: "conf.d/30-plugins.zsh"
# purpose: "Antidote static plugin loading and zsh completion initialization."
# shell: "zsh"
# ---

plugins_file="$ZDOTDIR/antidote/plugins.txt"
bundle_file="$ZDOTDIR/antidote/.zsh_plugins.zsh"

# Source antidote from Homebrew (makes the `antidote` function available).
if [[ -r "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/antidote/share/antidote/antidote.zsh" ]]; then
  source "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/antidote/share/antidote/antidote.zsh"
fi

if (( $+commands[antidote] )) && [[ -r "$plugins_file" ]]; then
  # Rebuild static plugin script only when source list changes.
  if [[ ! -f "$bundle_file" || "$plugins_file" -nt "$bundle_file" ]]; then
    antidote bundle < "$plugins_file" >| "$bundle_file"
  fi

  # Static source keeps startup deterministic and fast.
  [[ -r "$bundle_file" ]] && source "$bundle_file"
fi

autoload -Uz compinit
zcompdump_file="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"

# Optional fast mode: skips security checks on each startup.
if [[ -n "${ZSH_COMPINIT_FAST:-}" ]]; then
  compinit -C -d "$zcompdump_file"
else
  compinit -d "$zcompdump_file"
fi

unset plugins_file bundle_file zcompdump_file
