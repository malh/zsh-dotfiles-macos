# ---
# file: "conf.d/20-path.zsh"
# purpose: "Homebrew initialization and PATH/fpath ordering."
# shell: "zsh"
# ---

# Load Homebrew environment (Apple Silicon first, then Intel).
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Prepend user bins before inherited PATH entries.
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  $path
)

# Make Homebrew-provided completion functions discoverable.
if [[ -d "${HOMEBREW_PREFIX:-}/share/zsh/site-functions" ]]; then
  fpath=("${HOMEBREW_PREFIX}/share/zsh/site-functions" $fpath)
fi

# Deduplicate path-like arrays to avoid growth across reloads.
typeset -U path fpath
