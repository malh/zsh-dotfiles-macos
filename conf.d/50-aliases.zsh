# ---
# file: "conf.d/50-aliases.zsh"
# purpose: "Small aliases and helper functions."
# shell: "zsh"
# ---

# macOS/BSD-friendly ls defaults.
alias ls='ls -G'
alias la='ls -la'
alias ll='ls -lh'

# Redirect vim to Neovim when installed.
if (( $+commands[nvim] )); then
  alias vim='nvim'
fi

mkcd() {
  # Create and enter a directory in one command.
  mkdir -p "$1" && cd "$1" || return
}
