# ---
# file: "conf.d/10-options.zsh"
# purpose: "Interactive shell options and history behavior."
# shell: "zsh"
# ---

# Lines kept in memory / written to HISTFILE.
HISTSIZE="${HISTSIZE:-100000}"
SAVEHIST="${SAVEHIST:-100000}"

# History — aggressive deduplication, shared across sessions.
setopt APPEND_HISTORY          # append rather than overwrite the history file
setopt HIST_EXPIRE_DUPS_FIRST  # drop duplicates first when trimming history
setopt HIST_FIND_NO_DUPS       # skip dupes when scrolling through history
setopt HIST_IGNORE_ALL_DUPS    # remove older entry when a new dupe is added
setopt HIST_IGNORE_DUPS        # don't record consecutive duplicates
setopt HIST_IGNORE_SPACE       # commands starting with a space aren't saved
setopt HIST_REDUCE_BLANKS      # strip extra whitespace before saving
setopt HIST_SAVE_NO_DUPS       # don't write dupes to the history file
setopt INC_APPEND_HISTORY      # write each command immediately, not at exit
setopt SHARE_HISTORY           # share history between running sessions

# Quality-of-life.
setopt AUTO_CD                 # type a directory name to cd into it
setopt INTERACTIVE_COMMENTS    # allow # comments in interactive shells
setopt NO_BEEP                 # silence terminal bell
setopt EXTENDED_GLOB           # enable advanced glob operators (^, ~, #)
