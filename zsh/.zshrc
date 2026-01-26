# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
#export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="robbyrussell"

# FZF integration
source <(fzf --zsh)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Custom ZSH Prompt - Tokyo Night Style
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Colors (Tokyo Night palette)
typeset -A colors
colors=(
    [bg]='#1a1b26'
    [fg]='#c0caf5'
    [cyan]='#7dcfff'
    [blue]='#7aa2f7'
    [purple]='#bb9af7'
    [magenta]='#ff007c'
    [green]='#9ece6a'
    [orange]='#ff9e64'
    [red]='#f7768e'
    [yellow]='#e0af68'
    [gray]='#565f89'
)

# Git info function
git_prompt_info() {
    local ref
    ref=$(git symbolic-ref --short HEAD 2>/dev/null) || \
    ref=$(git rev-parse --short HEAD 2>/dev/null) || return 0

    local git_status=""
    local staged=$(git diff --cached --numstat 2>/dev/null | wc -l)
    local unstaged=$(git diff --numstat 2>/dev/null | wc -l)
    local untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l)

    # Build status indicators
    [[ $staged -gt 0 ]] && git_status+="%F{green}+$staged%f "
    [[ $unstaged -gt 0 ]] && git_status+="%F{yellow}~$unstaged%f "
    [[ $untracked -gt 0 ]] && git_status+="%F{red}?$untracked%f "

    # Check for stashes
    local stashes=$(git stash list 2>/dev/null | wc -l)
    [[ $stashes -gt 0 ]] && git_status+="%F{cyan}≡$stashes%f "

    # Ahead/behind
    local ahead=$(git rev-list --count @{upstream}..HEAD 2>/dev/null)
    local behind=$(git rev-list --count HEAD..@{upstream} 2>/dev/null)
    [[ $ahead -gt 0 ]] && git_status+="%F{green}↑$ahead%f"
    [[ $behind -gt 0 ]] && git_status+="%F{red}↓$behind%f"

    echo "%F{#bb9af7} $ref%f ${git_status}"
}

# Directory with home abbreviation and smart truncation
prompt_dir() {
    local dir="${PWD/#$HOME/~}"
    local max_len=40

    if [[ ${#dir} -gt $max_len ]]; then
        # Show first dir, ellipsis, and last 2 dirs
        local parts=(${(s:/:)dir})
        if [[ ${#parts[@]} -gt 3 ]]; then
            echo "${parts[1]}/…/${parts[-2]}/${parts[-1]}"
        else
            echo "$dir"
        fi
    else
        echo "$dir"
    fi
}

# Exit status indicator
prompt_status() {
    echo "%(?.%F{#9ece6a}❯%f.%F{#f7768e}❯%f)"
}

# SSH indicator
prompt_ssh() {
    [[ -n "$SSH_CONNECTION" ]] && echo "%F{#ff9e64}⟨ssh⟩%f "
}

# Virtual env indicator
prompt_venv() {
    [[ -n "$VIRTUAL_ENV" ]] && echo "%F{#7dcfff}(${VIRTUAL_ENV:t})%f "
}

# Jobs indicator
prompt_jobs() {
    echo "%(1j.%F{#e0af68}⚙%j%f .)"
}

# Build the prompt
build_prompt() {
    local nl=$'\n'

    # Top line: SSH + directory + git
    echo -n "$(prompt_ssh)"
    echo -n "%F{#7aa2f7}$(prompt_dir)%f"
    echo -n "$(git_prompt_info)"
    echo -n "$nl"

    # Bottom line: venv + jobs + arrow
    echo -n "$(prompt_venv)"
    echo -n "$(prompt_jobs)"
    echo -n "$(prompt_status) "
}

# Right prompt: time
build_rprompt() {
    echo "%F{#565f89}%T%f"
}

# Set prompts
setopt PROMPT_SUBST
PROMPT='$(build_prompt)'
RPROMPT='$(build_rprompt)'

# Transient prompt - cleaner history (optional, comment out if you don't like it)
zle-line-init() {
    emulate -L zsh
    [[ $CONTEXT == start ]] || return 0
    while true; do
        zle .recursive-edit
        local -i ret=$?
        [[ $ret == 0 && $KEYS == $'\4' ]] || break
        [[ -o ignore_eof ]] || exit 0
    done
    local saved_prompt=$PROMPT
    local saved_rprompt=$RPROMPT
    PROMPT='%(?.%F{#9ece6a}❯%f.%F{#f7768e}❯%f) '
    RPROMPT=''
    zle .reset-prompt
    PROMPT=$saved_prompt
    RPROMPT=$saved_rprompt
    if (( ret )); then
        zle .send-break
    else
        zle .accept-line
    fi
    return ret
}
zle -N zle-line-init
export PATH="$HOME/Documents/Scripts:$PATH"

alias python="/usr/bin/python3"
export PATH="$HOME/Applications:$PATH"
export EDITOR="nvim"

# Go paths
export PATH=$PATH:/usr/local/go/bin
export GOROOT=/usr/lib/go
export PATH=$PATH:~/go/bin

## TEST
export GTK_THEME=Tokyonight-Dark
export XCURSOR_SIZE=24

# From kali
# ~/.zshrc file for zsh interactive shells.
# see /usr/share/doc/zsh/examples/zshrc for examples

setopt autocd              # change directory just by typing its name
#setopt correct            # auto correct mistakes
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt

WORDCHARS=${WORDCHARS//\/} # Don't consider certain characters part of the word

# hide EOL sign ('%')
PROMPT_EOL_MARK=""

# configure key keybindings
bindkey -e                                        # emacs key bindings
bindkey ' ' magic-space                           # do history expansion on space
bindkey '^U' backward-kill-line                   # ctrl + U
bindkey '^[[3;5~' kill-word                       # ctrl + Supr
bindkey '^[[3~' delete-char                       # delete
bindkey '^[[1;5C' forward-word                    # ctrl + ->
bindkey '^[[1;5D' backward-word                   # ctrl + <-
bindkey '^[[5~' beginning-of-buffer-or-history    # page up
bindkey '^[[6~' end-of-buffer-or-history          # page down
bindkey '^[[H' beginning-of-line                  # home
bindkey '^[[F' end-of-line                        # end
bindkey '^[[Z' undo                               # shift + tab undo last action

my_ctrl_t_widget() {
  zle -I
  BUFFER="tmux-sessionizer.sh"
  zle accept-line
}
zle -N my_ctrl_t_widget
bindkey '^T' my_ctrl_t_widget

# enable completion features
autoload -Uz compinit
compinit -d ~/.cache/zcompdump
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' rehash true
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# History configurations
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=2000
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
#setopt share_history         # share command history data

# force zsh to show the complete history
alias history="history 0"

# configure `time` format
TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P'

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi


# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt




# enable color support of ls, less and man, and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    export LS_COLORS="$LS_COLORS:ow=30;44:" # fix ls color for folders with 777 permissions

    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias diff='diff --color=auto'
    alias ip='ip --color=auto'

    export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
    export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
    export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
    export LESS_TERMCAP_so=$'\E[01;33m'    # begin reverse video
    export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
    export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
    export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

    # Take advantage of $LS_COLORS for completion as well
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
    zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
fi

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

# enable auto-suggestions based on the history
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    . /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    # change suggestion color
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#999'
fi

# enable command-not-found if installed
if [ -f /etc/zsh_command_not_found ]; then
    . /etc/zsh_command_not_found
fi

# Ghostty ssh fix
if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
    export TERM=xterm-256color
fi


#fzf integration

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
