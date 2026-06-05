fish_add_path /opt/1Password \
    /Applications/1Password.app/Contents/MacOS \
    $HOME/.local/bin \
    $HOME/.spicetify \
    $HOME/.ghcup/bin
fish_add_path -a $HOME/bin \
    $HOME/.yarn/bin \
    $HOME/go/bin \
    /usr/local/sbin \
    /usr/local/go/bin

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

    test -f $HOME/.awskeys.sh; and source $HOME/.awskeys.sh

    set -l brew_prefix
    for prefix in /opt/homebrew /home/linuxbrew/.linuxbrew /usr/local
        if test -x $prefix/bin/brew
            set brew_prefix $prefix
            break
        end
    end
    if test -z "$brew_prefix"; and command -q brew
        set brew_prefix (brew --prefix)
    end
    if test -n "$brew_prefix"
        set -ax MANPATH $brew_prefix/opt/coreutils/libexec/gnuman
        fish_add_path \
            $brew_prefix/bin \
            $brew_prefix/opt/node/bin \
            $brew_prefix/opt/coreutils/bin \
            $brew_prefix/opt/coreutils/libexec/gnubin \
            $brew_prefix/opt/python/libexec/bin \
            $brew_prefix/opt/ruby/bin \
            $brew_prefix/opt/mysql-client/bin
    end

    command -q starship; and starship init fish | source; and enable_transience
    command -q mise; and mise activate fish | source
    command -q zoxide; and zoxide init --cmd cd fish | source
    command -q carapace; and carapace _carapace fish | source
    command -q fj; and fj completion fish 2>/dev/null | source
    command -q bdcli; and bdcli completion fish | source
    if command -q tv
        for mode in default insert
            bind --mode $mode ctrl-t tv_smart_autocomplete
            bind --mode $mode ctrl-r tv_shell_history
        end
    else
        command -q fzf; and fzf --fish | source
    end

    if status is-login
        set -l missing_tools
        command -q nvim; or set -a missing_tools "nvim      brew install neovim"
        command -q brew; or set -a missing_tools "brew      https://brew.sh"
        command -q starship; or set -a missing_tools "starship  brew install starship"
        command -q mise; or set -a missing_tools "mise      brew install mise"
        command -q zoxide; or set -a missing_tools "zoxide    brew install zoxide"
        command -q carapace; or set -a missing_tools "carapace  brew install carapace"
        command -q fj; or set -a missing_tools "fj        brew install forgejo-cli"
        command -q tv; or set -a missing_tools "tv        brew install television"
        command -q fzf; or set -a missing_tools "fzf       brew install fzf"
        command -q vivid; or set -a missing_tools "vivid     brew install vivid"
        command -q bdcli; or set -a missing_tools "bdcli     brew tap betterdiscord/tap/bdcli; brew install bdcli"

        if test (count $missing_tools) -gt 0
            set_color yellow
            echo "Optional shell tools missing:"
            set_color normal
            for tool in $missing_tools
                echo "  $tool"
            end
        end
    end
else
    mise activate fish --shims | source
end
