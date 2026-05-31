# Carapace honors XDG_CONFIG_HOME on macOS; keep its styles stow-managed.
set -q XDG_CONFIG_HOME; or set -gx XDG_CONFIG_HOME $HOME/.config

function vars_fzf
    set BACKGROUND "#232136"
    set FOREGROUND "#e0def4"
    set BG_PLUS "#393552"
    set BORDER "#56526e"
    set MARKER "#f6c177"
    set INFO "#9ccfd8"
    set HL "#f6c177"
    set LABEL "#908caa"
    set PROMPT "#3e8fb0"
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
        --preview 'fzf-preview.sh {}'"
    set -gx FZF_CTRL_T_OPTS "\
        --walker-skip .git,node_modules,target
        --bind 'ctrl-/:change-preview-window(down|hidden|)'"
    set -gx FZF_ALT_C_OPTS "\
        --walker-skip .git,node_modules,target
        --preview 'tree -C {}'"
    set -gx FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS $FZF_THEME"
    set -gx FZF_CTRL_R_OPTS "--bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort' \
        --color header:italic \
        --header 'Press CTRL-Y to copy command into clipboard'
        --preview ''"
end
vars_fzf

function vars_ls_colors
    command -q vivid; and set -gx LS_COLORS (vivid generate rose-pine-moon)
end
vars_ls_colors

set -gx HELPDIR /usr/local/share/zsh/helpfiles
set -gx MANPAGER 'nvim +Man!'
set -gx BAT_THEME "Rosé Pine Moon"
set -gx BAT_STYLE "plain"
set -gx LESSCHARSET utf-8
set -gx LESS "-FRmX"
set -gx PAGER "less $LESS"
set -gx ERL_AFLAGS "-kernel shell_history enabled"
set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml"
