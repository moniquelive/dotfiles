# TODO:
# zstyle :omz:plugins:ssh-agent agent-forwarding yes
# zstyle :omz:plugins:ssh-agent ssh-add-args --apple-load-keychain
# zstyle :omz:plugins:ssh-agent identities id_ed25519 id_rsa github_rsa
# zstyle :omz:plugins:ssh-agent lazy yes
# zstyle :omz:plugins:ssh-agent quiet yes

fish_add_path opt/1Password \
    /Applications/1Password.app/Contents/MacOS \
    $HOME/.local/bin \
    $HOME/.spicetify \
    $HOME/.ghcup/bin
fish_add_path -a $HOME/bin \
    $HOME/.yarn/bin \
    $HOME/go/bin \
    /usr/local/sbin \
    /usr/local/go/bin

if test -s /opt/homebrew/bin/brew
    set -l brew_prefix (/opt/homebrew/bin/brew --prefix)

    fish_add_path \
        $brew_prefix/bin \
        $brew_prefix/opt/node/bin \
        $brew_prefix/opt/coreutils/bin \
        $brew_prefix/opt/coreutils/libexec/gnubin \
        $brew_prefix/opt/python/libexec/bin \
        $brew_prefix/opt/ruby/bin \
        $brew_prefix/opt/mysql-client/bin

    set -ax MANPATH $brew_prefix/opt/coreutils/libexec/gnuman
end

test -f $HOME/.awskeys.sh; and source $HOME/.awskeys.sh

if status is-interactive
    # Commands to run in interactive sessions can go here
    set -gx EDITOR (command -q nvim; and echo nvim; or echo vim)
    abbr --add --position anywhere L "| $PAGER"

    bind ctrl-n history-prefix-search-forward
    bind ctrl-p history-prefix-search-backward
    bind down history-prefix-search-forward
    bind up history-prefix-search-backward

    starship init fish | source
    enable_transience

    mise activate fish | source
    fzf --fish | source
    zoxide init --cmd cd fish | source
end
