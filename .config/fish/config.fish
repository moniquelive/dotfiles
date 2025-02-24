# TODO:
# zstyle :omz:plugins:ssh-agent agent-forwarding yes
# zstyle :omz:plugins:ssh-agent ssh-add-args --apple-load-keychain
# zstyle :omz:plugins:ssh-agent identities id_ed25519 id_rsa github_rsa
# zstyle :omz:plugins:ssh-agent lazy yes
# zstyle :omz:plugins:ssh-agent quiet yes

fish_add_path -P /opt/1Password
fish_add_path -P /Applications/1Password.app/Contents/MacOS
fish_add_path -P $HOME/.local/bin
fish_add_path -P $HOME/.spicetify
fish_add_path -P $HOME/.ghcup/bin
fish_add_path -aP $HOME/bin
fish_add_path -aP $HOME/.yarn/bin
fish_add_path -aP $HOME/go/bin
fish_add_path -aP /usr/local/sbin
fish_add_path -aP /usr/local/go/bin

if test -s "/opt/homebrew/bin/brew"
  set -l brew_prefix (/opt/homebrew/bin/brew --prefix)

  fish_add_path -P \
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

    starship init fish | source
    mise activate fish | source
    fzf --fish | source
end
