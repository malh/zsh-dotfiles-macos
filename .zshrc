# ---
# file: ".zshrc"
# purpose: "Interactive zsh dispatcher for numbered modules in $ZDOTDIR/conf.d."
# shell: "zsh"
# ---

# Skip module loading for non-interactive shells.
[[ -o interactive ]] || return

# Optional startup profiling: DEBUG_ZSH=1 zsh -i
if [[ -n "${DEBUG_ZSH:-}" ]]; then
  zmodload zsh/zprof
fi

# Load modules in deterministic lexical order (00-, 10-, ... 99-).
for conf in "$ZDOTDIR/conf.d/"*.zsh(.N); do
  source "$conf"
done
unset conf

# Print profile report when enabled.
if [[ -n "${DEBUG_ZSH:-}" ]]; then
  zprof
fi
