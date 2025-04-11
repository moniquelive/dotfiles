function fzfgit
    git log --pretty=format:"%h %s (%cr) <%an>" -- $argv | fzf --tac --ansi --no-sort --reverse \
        --preview "git show -w -b --color-words --color=always {1} -- $argv" \
        --bind 'enter:accept' | cut -d' ' -f1
end
