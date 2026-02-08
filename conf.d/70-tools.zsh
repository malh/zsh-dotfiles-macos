# ---
# file: "conf.d/70-tools.zsh"
# purpose: "Late initialization for external shell tools."
# shell: "zsh"
# ---

# Starship prompt — runs late so it can hook into the shell after everything else loads.
if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi
