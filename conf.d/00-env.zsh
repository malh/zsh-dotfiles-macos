# ---
# file: "conf.d/00-env.zsh"
# purpose: "Base environment variables and XDG runtime defaults."
# shell: "zsh"
# ---

# Prefer Neovim when available, with a safe fallback.
if (( $+commands[nvim] )); then
  export EDITOR="nvim"
  export VISUAL="nvim"
else
  export EDITOR="vi"
  export VISUAL="vi"
fi

# Locale baseline. Do not force LC_ALL globally.
export LANG="${LANG:-en_US.UTF-8}"

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Ensure cache/state directories exist for zsh runtime files.
mkdir -p "$XDG_CACHE_HOME/zsh" "$XDG_STATE_HOME/zsh"

# Point Starship at the repo-managed config rather than its default location.
export STARSHIP_CONFIG="${STARSHIP_CONFIG:-$ZDOTDIR/starship/starship.toml}"

# Store history under XDG state, not $HOME.
export HISTFILE="${HISTFILE:-$XDG_STATE_HOME/zsh/history}"
