# zsh-dotfiles-macos

A clean, fast zsh setup for macOS — XDG-aligned, deterministic module loading, static plugin management via Antidote, and Starship prompt.

## Quick Install

```sh
curl -fsSL https://raw.githubusercontent.com/malh/zsh-dotfiles-macos/main/install.sh | bash
```

Optional overrides:

```sh
BRANCH=main TARGET_DIR=$HOME/.local/src/zsh-dotfiles \
  curl -fsSL https://raw.githubusercontent.com/malh/zsh-dotfiles-macos/main/install.sh | bash
```

The installer clones the repo and runs `bootstrap.sh`, which:

1. Installs Homebrew (if missing)
2. Installs packages: `antidote`, `starship`, `neovim`, `zsh-completions`, `fzf`
3. Backs up existing zsh config to `~/.local/state/zsh/bootstrap-backups/<timestamp>/`
4. Sets up XDG directories and writes `~/.zshenv`
5. Installs config into `~/.config/zsh`
6. Creates local override files (`05-secrets.zsh`, `99-local.zsh`) from templates
7. Generates the Antidote static plugin bundle
8. Runs syntax validation

After install, start a new shell:

```sh
exec zsh -l
```

## What You Get

- **XDG-compliant** — only `~/.zshenv` lives in `$HOME`; config in `~/.config/zsh`, state in `~/.local/state/zsh`, cache in `~/.cache/zsh`
- **Numbered module loading** — `conf.d/NN-*.zsh` files sourced in lexical order, each with a single responsibility
- **Static plugin loading** — Antidote bundles plugins at install time, not on every shell start
- **Starship prompt** — config tracked at `starship/starship.toml`
- **Neovim as default editor**
- **Fast startup** — targets under 100ms warm-cache

## Directory Layout

```text
~/.config/zsh/
├── .zshrc                        # loader — sources conf.d/*.zsh
├── .zprofile
├── .zlogin
├── .zlogout
├── conf.d/
│   ├── 00-env.zsh                # editor, locale, HISTFILE, STARSHIP_CONFIG
│   ├── 05-secrets.zsh            # untracked, chmod 600
│   ├── 10-options.zsh            # shell options and history behavior
│   ├── 20-path.zsh               # Homebrew shellenv, PATH/FPATH construction
│   ├── 30-plugins.zsh            # Antidote static loading + compinit
│   ├── 50-aliases.zsh            # aliases and small helpers
│   ├── 70-tools.zsh              # external tool init (fzf, starship, etc.)
│   └── 99-local.zsh              # untracked, machine-specific overrides
├── antidote/
│   ├── plugins.txt               # plugin source of truth
│   └── .zsh_plugins.zsh          # generated bundle (gitignored)
└── starship/
    └── starship.toml
```

## Customisation

### Adding plugins

Edit `~/.config/zsh/antidote/plugins.txt`, then regenerate the bundle:

```sh
antidote bundle < "$ZDOTDIR/antidote/plugins.txt" > "$ZDOTDIR/antidote/.zsh_plugins.zsh"
```

### Adding aliases or PATH entries

Edit the appropriate `conf.d/` module — `50-aliases.zsh` for aliases, `20-path.zsh` for PATH changes.

### Machine-specific config

Put anything local in `conf.d/99-local.zsh` (gitignored). For secrets and tokens, use `conf.d/05-secrets.zsh` (also gitignored, `chmod 600`).

Both files are created from tracked `.example.zsh` templates during install.

## Troubleshooting

**`antidote: command not found`**
— Run `brew install antidote` and ensure `30-plugins.zsh` guards against the missing command.

**No completions**
— Remove the stale dump and reinitialise:

```sh
rm -f "$XDG_CACHE_HOME/zsh"/zcompdump*
exec zsh -l
```

**Slow startup**
— Profile with `DEBUG_ZSH=1 zsh -i -c exit` or benchmark with `time zsh -i -c exit`. Look for expensive plugins or duplicated PATH entries.

**Unexpected `~/.zprofile`**
— Some installers (e.g. Homebrew) write directly to `~/.zprofile`. Move any managed content into `$ZDOTDIR/.zprofile`.

## Backups

Each run of `bootstrap.sh` creates a timestamped backup of your existing config:

- Stored in `~/.local/state/zsh/bootstrap-backups/<timestamp>/`
- Symlinked from `~/.config/zsh/backups.d/` (`latest` always points to the most recent)
- Includes a `merge-suggestions.md` to help migrate prior aliases, exports, and options into `conf.d/` modules

## License

MIT
