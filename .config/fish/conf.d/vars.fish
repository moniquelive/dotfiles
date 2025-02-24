function vars_fzf
    set -l BACKGROUND "#232136"
    set -l FOREGROUND "#e0def4"
    set -l BG_PLUS "#393552"
    set -l BORDER "#9ccfd8"
    set -l MARKER "#eb6f92"
    set -l INFO "#eb6f92"
    set -l HL "#f6c177"
    set -l LABEL "#6e6a86"
    set -l PROMPT "#3e8fb0"
    set -gx FZF_THEME "\
        --color=fg:$FOREGROUND,bg:$BACKGROUND,hl:$HL \
        --color=fg+:bold:$FOREGROUND,bg+:$BG_PLUS,hl+:$HL \
        --color=border:$BORDER,header:$INFO,gutter:$BACKGROUND \
        --color=spinner:$HL,info:$INFO,separator:$BACKGROUND \
        --color=pointer:bold:$HL,marker:$MARKER,prompt:$PROMPT \
        --color=preview-fg:$FOREGROUND,preview-bg:$BACKGROUND \
        --color=label:$LABEL"
    set -gx FZF_DEFAULT_OPTS "\
        -m --cycle --preview-window wrap --no-height \
        --preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'"
    set -gx FZF_CTRL_T_OPTS "\
        --walker-skip .git,node_modules,target
        --preview 'bat -n --color=always {}'
        --bind 'ctrl-/:change-preview-window(down|hidden|)'"
    set -gx FZF_ALT_C_OPTS "\
        --walker-skip .git,node_modules,target
        --preview 'tree -C {}'"
    set -gx FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS $FZF_THEME"
    set -gx FZF_CTRL_R_OPTS "--bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort' --color header:italic --header 'Press CTRL-Y to copy command into clipboard'"
end

set -gx HELPDIR /usr/local/share/zsh/helpfiles
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
set -gx BAT_THEME "Catppuccin Mocha"
set -gx BAT_STYLE "plain"
set -gx LESSCHARSET utf-8
set -gx LESS "-FRmX"
set -gx PAGER "less $LESS"
set -gx ERL_AFLAGS "-kernel shell_history enabled"
set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml"

vars_fzf
