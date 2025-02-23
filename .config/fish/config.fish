if status is-interactive
    # Commands to run in interactive sessions can go here
    alias vim nvim
    alias lg lazygit
    abbr --add gs "git status -sb"
    abbr --add --position anywhere G "| grep"
    abbr --add --position anywhere GV "| grep -v"
    set -U fish_greeting ""
    starship init fish | source
end
