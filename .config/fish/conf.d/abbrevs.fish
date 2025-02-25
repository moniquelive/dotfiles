if status is-interactive
    abbr --add - "cd -"
    abbr --add gs "git status -sb"
    abbr --add gd "git difftool --no-prompt --tool=mvimdiff"
    abbr --add --position anywhere G "| grep"
    abbr --add --position anywhere GV "| grep -v"
    abbr --add --position anywhere A "| awk"
    abbr --add --position anywhere H "| head"
    abbr --add --position anywhere L "| $PAGER"
    abbr --add --position anywhere R "| ruby -e"
    abbr --add --position anywhere S "| sed"
    abbr --add --position anywhere T "| tail"
    abbr --add --position anywhere V "| vim -R -"
    abbr --add --position anywhere W "| wc"
    abbr --add --position anywhere Z '| fzf'
end
