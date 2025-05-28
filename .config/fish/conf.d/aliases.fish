if status is-interactive
    alias vim nvim

    alias g git
    alias ga "git add"
    alias gb "git branch"
    alias gba "git branch -a"
    alias gc "git commit"
    alias gcam "git commit -am"
    alias gp "git push"
    alias gl "git pull"
    alias grb "git rebase"
    alias grbc "git rebase --continue"
    alias grba "git rebase --abort"
    alias gm "git merge"
    alias gma "git merge --abort"
    alias gmc "git merge --continue"
    alias gco "git checkout"
    alias gr "git remote"
    alias gra "git remote add"
    alias grv "git remote -v"
    alias grh "git reset"
    alias grhh "git reset --hard"
    alias gf "git fetch"
    alias gsta "git stash push"
    alias gstc "git stash clear"
    alias gstd "git stash drop"
    alias gstl "git stash list"
    alias gstp "git stash pop"
    alias gwipe "git reset --hard && git clean --force -df"

    alias ... 'cd ../..'
    alias .... 'cd ../../..'
    alias l 'ls -l'
    alias ll 'ls -l'
    alias lrt 'ls -lrt'
    alias la 'ls -a'
    alias ls 'ls --color=auto --group-directories-first'
    alias lg "lazygit --use-config-file=$HOME/.config/lazygit/config.yml"

    alias yt "yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4'"
    alias fd fdfind
    alias tree 'tree -SA --gitignore'

    alias aws-cli 'docker run --rm -it -v ~/.aws:/root/.aws amazon/aws-cli'
    alias afd 'aws --profile akad_front_dev'
    alias afp 'aws --profile akad_front_prod'
    alias abp 'aws --profile akad_back_prod'
    alias afh 'aws --profile akad_front_homol'
    alias ass 'aws --profile akad_shared_services'

    alias bubu='brew update;and brew outdated; and brew upgrade; and brew upgrade --greedy;and brew upgrade --cask;and brew cleanup; and brew autoremove; mise p up; and mise prune; and mise up; and mise up'

    alias fzfbrew "brew rm (brew ls | fzf --preview='brew info {}')"

    function python_venv --on-variable PWD
        set myvenv ./venv
        if test -d $myvenv
            source $myvenv/bin/activate.fish
        else if type -q deactivate
            deactivate
        end
    end

    function exercism_aliases --on-variable PWD
        if string match -irq exercism $PWD
            alias s 'exercism s'
        else
            functions -e s
        end
    end
end
