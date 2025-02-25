if status is-interactive
    alias vim nvim

    alias ... 'cd ../..'
    alias .... 'cd ../../..'
    alias g git
    alias l ls
    alias ll 'ls -l'
    alias la 'ls -a'
    alias ls 'ls --color=auto --group-directories-first'
    alias lg "lazygit --use-config-file=$HOME/.config/lazygit/config.yml"

    alias yt "yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4'"
    alias fd fdfind
    alias tree 'tree -SA --gitignore'
    alias ya yazi

    alias aws-cli 'docker run --rm -it -v ~/.aws:/root/.aws amazon/aws-cli'
    alias afd 'aws --profile akad_front_dev'
    alias afp 'aws --profile akad_front_prod'
    alias abp 'aws --profile akad_back_prod'
    alias afh 'aws --profile akad_front_homol'
    alias ass 'aws --profile akad_shared_services'

    alias bubu='brew update;and brew outdated; and brew upgrade; and brew upgrade --greedy;and brew upgrade --cask;and brew cleanup; and brew autoremove'

    alias fzfbrew "brew rm (brew ls | fzf --preview='brew info {}')"

    function listen
        lsof -nP -i :$argv | grep LISTEN
    end

    function python_venv --on-variable PWD
        set -l myvenv ./venv
        if test -d $myvenv
            source $myvenv/bin/activate.fish
        else if type -q deactivate
            deactivate
        end
    end

    function fzfrmimage
        set -l images (docker image ls | tail -n +2 | fzf | while read l; echo $l | string split -n -f3 ' '; end)
        test -n "$images"; and docker image rm $images
    end

    function fzfrmservice
        set -l services (docker service ls | tail -n +2 | fzf | while read l; echo $l | string split -n -f1 ' '; end)
        test -n "$services"; and docker service rm $services
    end
end
