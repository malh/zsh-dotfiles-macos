# ---
# file: "conf.d/70-tools.zsh"
# purpose: "Late initialization for external shell tools."
# shell: "zsh"
# ---

if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi
