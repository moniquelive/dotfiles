if status is-interactive
    alias vim nvim

    alias l ls
    alias ls 'gls --color=auto --group-directories-first'
    alias tree 'tree -SA'
    alias lg "lazygit --use-config-file=$HOME/.config/lazygit/config.yml"

    alias yt "yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4'"
    alias fd fdfind
    alias tree 'tree --gitignore'
    alias ya yazi

    alias aws-cli 'docker run --rm -it -v ~/.aws:/root/.aws amazon/aws-cli'
    alias afd 'aws --profile akad_front_dev'
    alias afp 'aws --profile akad_front_prod'
    alias abp 'aws --profile akad_back_prod'
    alias afh 'aws --profile akad_front_homol'
    alias ass 'aws --profile akad_shared_services'
end
