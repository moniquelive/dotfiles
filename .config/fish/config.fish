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

test -z "$SSH_ENV"; and set -xg SSH_ENV $HOME/.ssh/environment
__ssh_agent_is_started; or __ssh_agent_start

# function starship_transient_prompt_func
#     starship module -s $status character
# end

if status is-interactive
    # Commands to run in interactive sessions can go here
    set -gx EDITOR (command -q nvim; and echo nvim; or echo vim)
    abbr --add --position anywhere L "| $PAGER"

    bind ctrl-n history-prefix-search-forward
    bind ctrl-p history-prefix-search-backward
    bind down history-prefix-search-forward
    bind up history-prefix-search-backward

    command -q starship; and starship init fish | source; and enable_transience
    command -q mise; and mise activate fish | source
    command -q zoxide; and zoxide init --cmd cd fish | source
    command -q tailscale; and tailscale completion fish | source
    if command -q tv
        tv init fish | source
    else
        command -q fzf; and fzf --fish | source
    end
    command -q carapace; and carapace _carapace | source
end
