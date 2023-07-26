# BENCHMARKING
# zmodload zsh/zprof
#----------------------------------------------------------------------------

## Interactive shell ##

skip_global_compinit=1
zmodload zsh/mathfunc
autoload -Uz compaudit compinit run-help
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit;
else
  compinit -C;
fi

autoload -Uz run-help-git
export HELPDIR=/usr/local/share/zsh/helpfiles

# search on zshall man page
zman() { MANPAGER="less -g -s '+/^       "$1"'" man zshall }

autoload -Uz zmv
alias mmv='noglob zmv -W'

# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Nicer history
HISTSIZE=100000
SAVEHIST=$HISTSIZE
REPORTTIME=10
#WORDCHARS=${WORDCHARS//[&=\/;\!#%\{]}
WORDCHARS='*?_[]~=&;!#$%^(){}'
HISTFILE=~/.zsh_history

# Uncomment following line if you want to disable autosetting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"

#-------------------------------------------------------------- gcloud sdk ---
# The next line updates PATH for the Google Cloud SDK.
[[ -f "${HOME}/prj/google-cloud-sdk/path.zsh.inc" ]] && source "${HOME}/prj/google-cloud-sdk/path.zsh.inc"
# The next line enables shell command completion for gcloud.
[[ -f "${HOME}/prj/google-cloud-sdk/completion.zsh.inc" ]] && source "${HOME}/prj/google-cloud-sdk/completion.zsh.inc"

#----------------------------------------------------------------- plugins ---
plugins=(
  cp colored-man-pages command-not-found common-aliases copybuffer
  dirpersist
  history
  jsontools
  sudo
  z
)
# plugins for binaries
for p in aws emacs fzf gcloud docker docker-compose gem git \
          gpg-agent pyenv rails redis-cli ros rsync rvm \
                  stack tig tmux yum
do
  (( $+commands[$p] )) && plugins+=($p)
done

# conditional plugins
if (( $+commands[hostname] )); then
  [[ `hostname` != "ip-172-31-37-67" ]] && plugins+=(ssh-agent)
elif (( $+commands[hostnamectl] )); then
  [[ `hostnamectl hostname` != "ip-172-31-37-67" ]] && plugins+=(ssh-agent)
fi

(( $+commands[brew] ))      && plugins+=(brew macos gnu-utils)
(( $+commands[bundle] ))    && plugins+=(bundler)
(( $+commands[dpkg] ))      && plugins+=(ubuntu)
(( $+commands[git] ))       && plugins+=(git-escape-magic github gitignore)
(( $+commands[go] ))        && plugins+=(golang)
[[ -d "$HOME/.nvm" ]]       && plugins+=(nvm)
(( $+commands[pacman] ))    && plugins+=(archlinux)
(( $+commands[rake] ))      && plugins+=(rake-fast)
(( $+commands[rg] ))        && plugins+=(ripgrep)
(( $+commands[systemctl] )) && plugins+=(systemd)

# zshlovers(https://grml.org/zsh/zsh-lovers.html)
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3))numeric)'
zstyle ':completion:*:functions' ignored-patterns '_*'

# loadup ssh-agent (<3)
if (( $+commands[hostname] )); then
  # TODO: change to uname ?
  if [[ `hostname` != "ip-172-31-37-67" ]]; then
    zstyle :omz:plugins:ssh-agent agent-forwarding yes
    zstyle :omz:plugins:ssh-agent ssh-add-args --apple-load-keychain
    zstyle :omz:plugins:ssh-agent identities id_ed25519 id_rsa github_rsa
    zstyle :omz:plugins:ssh-agent lazy yes
    zstyle :omz:plugins:ssh-agent quiet yes
  fi
elif (( $+commands[hostnamectl] )); then
  if [[ `hostnamectl hostname` != "ip-172-31-37-67" ]]; then
    zstyle :omz:plugins:ssh-agent agent-forwarding yes
    zstyle :omz:plugins:ssh-agent identities id_ed25519 id_rsa
    zstyle :omz:plugins:ssh-agent lazy yes
  fi
fi

# .ssh/config FTW!
if [[ -r ~/.ssh/config ]]; then
  h=($h $(awk '/^[hH]ost/ {for(i=2;i<=NF;++i) print $i}' ~/.ssh/config))
  if [[ $#h -gt 0 ]]; then
    zstyle ':completion:*:ssh:*' hosts $h
    zstyle ':completion:*:slogin:*' hosts $h
  fi
  unset h
fi

unset SCRIPT_NAME

#---------------------------------------------------------------- load OMZ ---
[[ -s "$ZSH/oh-my-zsh.sh" ]] && source $ZSH/oh-my-zsh.sh
# unalias fd

# set these after omz
# export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# export MANROFFOPT="-c"
export BAT_THEME="gruvbox-dark"
export BAT_STYLE="plain"
export LESSCHARSET=utf-8
export LESS="-FRmX"
export PAGER="less ${LESS}"
export EDITOR=$( (( $+commands[nvim] )) && echo nvim || echo vim )
export ERL_AFLAGS="-kernel shell_history enabled"


#----------------------------------------------------------------- aliases ---

# TMUX
unalias t
alias t=tmux
compdef _tmux t

alias ls='ls --color=auto --group-directories-first'
alias ri='ri -Tf ansi'
alias rm='rm -I'
alias tree='tree -SA'
alias gd="git difftool --no-prompt --tool=mvimdiff"
alias gs='git status -sb'
alias od='od -Ax -tx1z'
alias hexdump='hexdump -C'
alias where="command -v"
alias mv='nocorrect mv -v'
alias cp='nocorrect cp -v'
alias mkdir='nocorrect mkdir'
alias burniso='hdiutil makehybrid -iso -joliet -o $1.iso $2'
alias icat='kitty +kitten icat'
#alias ssh='TERM=xterm ssh'
#alias ssh="kitty +kitten ssh"
alias yt="youtube-dl -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4'"
alias afd='aws --profile akad_front_dev'
alias afp='aws --profile akad_front_prod'
alias abp='aws --profile akad_back_prod'
alias afh='aws --profile akad_front_homol'
alias ass='aws --profile akad_shared_services'
#[ -f /usr/local/bin/bat -o -f /bin/bat ] && alias cat='bat -pp'
#[[ -x /usr/local/bin/emacs ]] && alias emacs='/usr/local/bin/emacs -nw $*'
(( $+commands[defaults] )) && alias dockspaceleft='defaults write com.apple.dock persistent-apps -array-add '\''{tile-data={}; tile-type="spacer-tile";}'\''; killall Dock'
(( $+commands[defaults] )) && alias dockspaceright='defaults write com.apple.dock persistent-others -array-add '\''{tile-data={}; tile-type="spacer-tile";}'\''; killall Dock'
[[ -x /usr/bin/fdfind ]] && alias fd='fdfind'
[[ $USER == ubuntu ]] && alias aws-cli='docker run --rm -it -v ~/.aws:/root/.aws amazon/aws-cli'
(( $+commands[nvim] )) && alias vim=nvim

#---------------------------------------------------------- global aliases ---
alias -g A="| awk"
alias -g G="| grep"
alias -g GV="| grep -v"
alias -g H="| head"
alias -g L="| $PAGER"
alias -g P=' --help | less'
alias -g R="| ruby -e"
alias -g S="| sed"
alias -g T="| tail"
alias -g V="| vim -R -"
alias -g U=' --help | head'
alias -g W="| wc"
alias -g Z='| fzf'

#---------------------------------------------------------- suffix aliases ---
alias -s zip=zipinfo
alias -s tgz=gzcat
alias -s gz=gzcat
alias -s tbz=bzcat
alias -s bz2=bzcat
alias -s java=vim
alias -s c=vim
alias -s h=vim
alias -s C=vim
alias -s cpp=vim
alias -s php=vim
# alias -s py=vim
# alias -s rb=vim
alias -s txt=vim
alias -s xml=vim

#-------------------------------------------------------------- EMACS emul ---
bindkey -e
bindkey '\e[1;3C' forward-word
bindkey '\e[1;3D' backward-word
bindkey '\e\e[C' forward-word
bindkey '\e\e[D' backward-word

#------------------------------------------------------ History completion ---
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey '\eOA' up-line-or-beginning-search
bindkey '\eOB' down-line-or-beginning-search
bindkey '^P' up-line-or-beginning-search
bindkey '^N' down-line-or-beginning-search

# edit command line in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

#---------------------------------------------------------------- ZSH opts ---
setopt auto_cd
setopt auto_list
setopt auto_param_keys
setopt auto_param_slash
setopt auto_pushd
setopt auto_resume
setopt brace_ccl
#setopt complete_aliases
setopt extended_glob
setopt extended_history
setopt hash_cmds
setopt hist_expand
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_no_store
setopt hist_reduce_blanks
setopt inc_append_history
setopt list_packed
setopt list_rows_first
setopt list_types
setopt long_list_jobs
setopt magic_equal_subst
setopt mark_dirs
setopt multios
setopt no_beep
setopt no_hup
#setopt no_clobber
setopt no_menu_complete
setopt numeric_glob_sort
setopt path_dirs
setopt print_eight_bit
setopt pushd_ignore_dups
setopt pushd_minus
setopt pushd_silent
setopt rm_star_wait
setopt share_history
setopt transient_rprompt

unsetopt promptcr
unsetopt correctall
unsetopt hist_verify
unsetopt print_exit_value

#--------------------------------------------------------------------- FZF ---
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# Setting fd as the default source for fzf
# export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_DEFAULT_COMMAND="fdfind --hidden --follow --exclude '.git' --exclude 'node_modules'"
BACKGROUND="#171A1A"
FOREGROUND="#EBDBB2"
COMMENT="#665C54"
MILK="#E7D7AD"
ERROR_RED="#CC241D"
ORANGE="#D65D0E"
BRIGHT_YELLOW="#FABD2F"
SOFT_YELLOW="#EEBD35"
LIGHT_BLUE="#7FA2AC"
FZF_THEME="--color=fg:${FOREGROUND} --color=bg:${BACKGROUND} --color=hl:${BRIGHT_YELLOW} --color=fg+:bold:${FOREGROUND} --color=bg+:${COMMENT} --color=hl+:${BRIGHT_YELLOW} --color=gutter:${BACKGROUND} --color=info:${ORANGE} --color=separator:${BACKGROUND} --color=border:${MILK} --color=label:${SOFT_YELLOW} --color=prompt:${LIGHT_BLUE} --color=spinner:${BRIGHT_YELLOW} --color=pointer:bold:${BRIGHT_YELLOW} --color=marker:${ERROR_RED} --color=header:${ORANGE} --color=preview-fg:${FOREGROUND} --color=preview-bg:${BACKGROUND}"
export FZF_DEFAULT_OPTS="\
  -m --cycle --preview-window wrap \
  --preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} ${FZF_THEME}"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fdfind --hidden --follow --exclude '.git' --exclude 'node_modules' --type d ."

# for more info see fzf/shell/completion.zsh
_fzf_compgen_path() {
    fdfind . "$1"
}
_fzf_compgen_dir() {
    fdfind --type d . "$1"
}

# like normal z when used with arguments but displays an fzf prompt when used without.
unalias z 2> /dev/null
z() {
    [ $# -gt 0 ] && zshz "$*" && return
    cd "$(zshz -l 2>&1 | fzf --no-preview --height 40% --nth 2.. --reverse --inline-info +s --tac --query "${*##-* }" | sed 's/^[0-9,.]* *//')"
}

fzfrmimage() {
  docker image rm $(docker image ls | tail -n +2 | fzf | while read l; do echo $l | awk '{printf "%s:%s ", $1,$2}'; done)
}

fzfrmservice() {
  docker service rm $(docker service ls | tail -n +2 | fzf | while read l; do echo $l | awk '{printf "%s ", $2}'; done)
}

fzfbrew() {
  brew rm `brew ls | fzf --preview='brew info {}'`
}

#-----------------------------------------------------------------------------
listen() {
  lsof -nP -i":$1" | grep LISTEN
}

#-----------------------------------------------------------------------------
n ()
{
    # Block nesting of nnn in subshells
    if [ -n $NNNLVL ] && [ "${NNNLVL:-0}" -ge 1 ]; then
        echo "nnn is already running"
        return
    fi

    # The default behaviour is to cd on quit (nnn checks if NNN_TMPFILE is set)
    # To cd on quit only on ^G, remove the "export" as in:
    #     NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    # NOTE: NNN_TMPFILE is fixed, should not be modified
    NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

    # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
    # stty start undef
    # stty stop undef
    # stty lwrap undef
    # stty lnext undef

    #export ICONLOOKUP=1
    export FZF_DEFAULT_COMMAND='fdfind -t d'
    export NNN_PLUG='f:fzcd;o:fzopen;p:mocplay;d:diffs;t:preview-tui;v:preview-tabbed'

    nnn -a -A -R -Te -Pt "$@"

    if [ -f "$NNN_TMPFILE" ]; then
            . "$NNN_TMPFILE"
            rm -f "$NNN_TMPFILE" > /dev/null
    fi
}

#------------------------------------------------------------ chpwd pyvenv ---
python_venv() {
  MYVENV=./venv
  [[ -d $MYVENV ]] && source $MYVENV/bin/activate
  [[ ! -d $MYVENV ]] && deactivate > /dev/null 2>&1
}
autoload -U add-zsh-hook
add-zsh-hook chpwd python_venv

python_venv

[[ -e $HOME/.dircolors ]] && eval $(dircolors -b $HOME/.dircolors)
[[ -f $HOME/.config/op/plugins.sh ]] && source $HOME/.config/op/plugins.sh

[[ -f $HOME/.cargo/env ]] && source $HOME/.cargo/env
[[ -f $HOME/.ghcup/env ]] && source $HOME/.ghcup/env

#--------------------------------------------------------- starship prompt ---
eval "$(starship init zsh)"

#----------------------------------------------------------------------------
# BENCHMARKING (END)
# zprof

# # Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
# export PATH="$PATH:$HOME/.rvm/bin"