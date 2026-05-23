# Doom Emacs Starter Guide

## What is Doom Emacs?

Doom Emacs is a configuration framework for GNU Emacs built by Henrik Lissner. It provides a curated, opinionated setup with sensible defaults, Vim-style keybindings (via Evil mode), and a modular system for enabling features on demand. It's fast, well-organized, and beginner-friendly compared to configuring Emacs from scratch.

## Installation

### Prerequisites

- Emacs 29+ (native-comp recommended)
- Git 2.23+
- ripgrep
- fd (optional but recommended)

### Install Steps

```bash
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install
```

Add `~/.config/emacs/bin` to your `$PATH` so you can run `doom` commands directly.

### Daemon vs Client

Emacs supports a daemon/client model that drastically improves startup time. Instead of launching a full Emacs instance each time, you start a persistent daemon once and connect to it with lightweight clients.

#### Starting the Daemon

```bash
# Start the daemon in the background
emacs --daemon

# Or use systemd (recommended for auto-start)
systemctl --user enable --now emacs
```

The daemon loads your full Doom config once and keeps it in memory.

#### Connecting with emacsclient

```bash
# Open a file in a new frame (window)
emacsclient -c file.txt

# Open in the terminal (no GUI frame)
emacsclient -t file.txt

# If no daemon is running, start one automatically
emacsclient -ca '' file.txt
```

| Flag  | Meaning                                              |
|-------|------------------------------------------------------|
| `-c`  | Create a new graphical frame                         |
| `-t`  | Open in the terminal (tty)                           |
| `-a`  | Alternate editor if daemon isn't running (`''` = start daemon) |
| `-n`  | Don't wait for the frame to close (return to shell)  |

#### Recommended Alias

```bash
alias emacs="emacsclient -ca ''"
```

This transparently starts the daemon if needed, so `emacs` always connects instantly.

#### Stopping the Daemon

```bash
# From a shell
emacsclient -e '(kill-emacs)'

# Or from inside Emacs
SPC q q   # quit Emacs (kills the frame)
SPC q Q   # quit Emacs and kill the daemon
```

#### Why Use the Daemon?

- **Near-instant startup** - clients connect in milliseconds vs seconds for a fresh Emacs
- **Shared state** - all frames share buffers, kill ring, undo history, and LSP sessions
- **Persistent background** - closing a frame doesn't lose your session
- **System integration** - the systemd unit ensures the daemon is always available after login

### Key Commands

| Command          | Description                                      |
|------------------|--------------------------------------------------|
| `doom sync`      | Sync config after editing init.el or packages.el |
| `doom upgrade`   | Update Doom and its packages                     |
| `doom doctor`    | Diagnose common issues                           |
| `doom env`       | Regenerate your envvar file                      |
| `doom clean`     | Clear caches and build files                     |

---

## Configuration Files

Doom's config lives in `~/.config/doom/` (or `~/.doom.d/`):

| File           | Purpose                                                        |
|----------------|----------------------------------------------------------------|
| `init.el`      | Enable/disable Doom modules (the module index)                 |
| `config.el`    | Your personal configuration (keybinds, settings, theme, etc.)  |
| `packages.el`  | Declare additional packages to install                         |

After editing `init.el` or `packages.el`, always run `doom sync`.

---

## Core Keybindings

Doom uses Evil mode (Vim emulation) by default. The leader key is `SPC` and the local leader is `SPC m`.

### General Navigation

| Key         | Action                          |
|-------------|---------------------------------|
| `SPC .`     | Find file                       |
| `SPC ,`     | Switch buffer                   |
| `SPC f r`   | Recent files                    |
| `SPC SPC`   | Find file in project            |
| `SPC b k`   | Kill buffer                     |
| `SPC b b`   | Switch buffer (all)             |
| `SPC q q`   | Quit Emacs                      |

### Search

| Key         | Action                          |
|-------------|---------------------------------|
| `SPC s p`   | Search in project (ripgrep)     |
| `SPC s s`   | Search in current buffer        |
| `SPC s d`   | Search in directory             |
| `SPC s i`   | Search with imenu (jump to symbol) |

### Windows

| Key         | Action                          |
|-------------|---------------------------------|
| `SPC w v`   | Vertical split                  |
| `SPC w s`   | Horizontal split                |
| `SPC w w`   | Cycle windows                   |
| `SPC w q`   | Close window                    |
| `C-h/j/k/l` | Navigate windows (vi-style)    |

### Project Management (Projectile)

| Key         | Action                          |
|-------------|---------------------------------|
| `SPC p p`   | Switch project                  |
| `SPC p f`   | Find file in project            |
| `SPC p s`   | Search in project               |
| `SPC p t`   | Open terminal in project root   |

### Code / LSP

| Key         | Action                          |
|-------------|---------------------------------|
| `gd`        | Go to definition                |
| `gr`        | Find references                 |
| `K`         | Show documentation (hover)      |
| `SPC c a`   | Code actions                    |
| `SPC c r`   | Rename symbol                   |
| `SPC c d`   | Jump to definition              |
| `SPC c f`   | Format buffer                   |

### Git (Magit)

| Key         | Action                          |
|-------------|---------------------------------|
| `SPC g g`   | Open Magit status               |
| `SPC g b`   | Git blame                       |
| `SPC g l`   | Git log                         |

### Org Mode

| Key           | Action                        |
|---------------|-------------------------------|
| `SPC m t`     | Toggle TODO state             |
| `SPC m d`     | Set deadline                  |
| `SPC m s`     | Set schedule                  |
| `SPC n a`     | Org agenda                    |
| `SPC n c`     | Org capture                   |

---

## Module System

Doom's power comes from its module system. Modules are toggled in `init.el` and are grouped by category:

### Completion
- **company** - Auto-completion framework
- **vertico** - Minibuffer completion (replaces ivy/helm)

### UI
- **doom** - Doom's theme and modeline
- **treemacs** - File tree sidebar
- **tabs** - Workspace tabs
- **zen** - Distraction-free writing mode

### Editor
- **evil** - Vim emulation
- **snippets** - Expand abbreviations into templates (yasnippet)
- **format** - Auto-formatting with formatters
- **fold** - Code folding

### Tools
- **magit** - Best Git interface in existence
- **lsp** - Language Server Protocol support
- **debugger** - DAP-based debugging
- **docker** - Dockerfile/docker-compose support
- **direnv** - Per-directory environment variables
- **rgb** - Colorize color codes in buffers
- **vterm** - Terminal emulator inside Emacs

### Languages
Doom has modules for most languages out of the box:

`python`, `rust`, `go`, `javascript`, `typescript`, `lua`, `sh`, `nix`, `cc` (C/C++), `java`, `ruby`, `haskell`, `ocaml`, `zig`, `web` (HTML/CSS), `json`, `yaml`, `markdown`, `org`, `latex`, and many more.

Enable them by uncommenting lines in `init.el`.

### Enabling a Module with Flags

Some modules accept flags for extra features:

```elisp
;; in init.el
(python +lsp +pyright)    ; Python with LSP using pyright
(rust +lsp)               ; Rust with LSP
(org +pretty +journal)    ; Org with prettified symbols and journaling
```

---

## Magit: Git Powerhouse

Magit is the standout Git interface. Open it with `SPC g g`.

### Common Magit Actions

| Key (in Magit) | Action                        |
|----------------|-------------------------------|
| `s`            | Stage file/hunk               |
| `u`            | Unstage file/hunk             |
| `c c`          | Commit                        |
| `P p`          | Push                          |
| `F p`          | Pull                          |
| `b b`          | Switch branch                 |
| `b c`          | Create branch                 |
| `l l`          | Log (current branch)          |
| `d d`          | Diff                          |
| `r i`          | Interactive rebase             |
| `Z Z`          | Stash                         |
| `?`            | Show all available actions     |

---

## Org Mode: Notes, Tasks, and More

Org mode is Emacs' killer feature for note-taking, task management, and literate programming.

### Key Capabilities
- **Outlining** - Hierarchical headings with `TAB` to fold/unfold
- **TODO management** - Track tasks with states (TODO, DONE, custom)
- **Agenda** - Aggregate tasks across files with deadlines/schedules
- **Capture** - Quickly jot down notes/tasks from anywhere
- **Tables** - Spreadsheet-like tables with formulas
- **Code blocks** - Execute code inline (Babel), supports dozens of languages
- **Export** - Export to HTML, PDF (via LaTeX), Markdown, and more

### Example Org File

```org
* Project Tasks
** TODO Set up CI pipeline
   DEADLINE: <2026-04-01>
** DONE Write deployment script
   CLOSED: [2026-03-25]

* Meeting Notes
** Weekly Standup [2026-03-28]
   - Discussed migration plan
   - Action items assigned

* Code Example
#+begin_src python
print("Hello from Org!")
#+end_src
```

---

## Package Management

Add packages in `~/.config/doom/packages.el`:

```elisp
;; Install from MELPA/ELPA
(package! some-package)

;; Install from a Git repo
(package! some-package :recipe (:host github :repo "user/repo"))

;; Disable a Doom-bundled package
(package! some-package :disable t)

;; Pin a package to a specific commit
(package! some-package :pin "abc123")
```

Then run `doom sync` to install.

---

## Customization Examples

Add these to `~/.config/doom/config.el`:

```elisp
;; Set theme
(setq doom-theme 'doom-one)

;; Set font
(setq doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 14))

;; Set line numbers
(setq display-line-numbers-type 'relative)

;; Set org directory
(setq org-directory "~/org/")

;; Custom keybinding
(map! :leader
      :desc "Open terminal" "o t" #'+vterm/toggle)
```

---

## Useful Tips

1. **Which-key** - Press `SPC` and wait; a popup shows all available next keys
2. **M-x** (`SPC :`) - Run any Emacs command by name
3. **SPC h** - Help menu (describe functions, variables, keybindings, etc.)
4. **SPC h r r** - Reload your config without restarting
5. **SPC t** - Toggle menu (line numbers, word wrap, themes, etc.)
6. **Evil tutor** - Run `M-x evil-tutor-start` to learn Vim keybindings
7. **Doom uses lazy loading** - Packages load on demand, keeping startup fast

---

## Resources

- Doom Emacs GitHub: https://github.com/doomemacs/doomemacs
- Doom Emacs Discourse: https://discourse.doomemacs.org
- Doom Emacs Module Index: https://github.com/doomemacs/doomemacs/blob/master/docs/modules.org
- Emacs Wiki: https://www.emacswiki.org
- Org Mode Manual: https://orgmode.org
