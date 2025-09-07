function fzfbrew --wraps="brew rm (brew ls | fzf --preview='brew info {}')"
    brew rm (brew ls --formula | fzf --tac --preview='brew info {}' --preview-window=right,60%) $argv
end
