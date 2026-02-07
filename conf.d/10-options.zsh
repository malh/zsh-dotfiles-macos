# ---
# file: "conf.d/10-options.zsh"
# purpose: "Interactive shell options and history behavior."
# shell: "zsh"
# ---

HISTSIZE="${HISTSIZE:-100000}"
SAVEHIST="${SAVEHIST:-100000}"

# History behavior tuned for deduplication and useful recall.
setopt APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# Lightweight quality-of-life options.
setopt AUTO_CD
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt EXTENDED_GLOB
