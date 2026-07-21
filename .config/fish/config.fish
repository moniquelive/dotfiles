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
        set -l optional_tools \
            "nvim|brew install neovim" \
            "brew|https://brew.sh" \
            "starship|brew install starship" \
            "mise|brew install mise" \
            "zoxide|brew install zoxide" \
            "carapace|brew install carapace" \
            "fj|brew install forgejo-cli" \
            "tv|brew install television" \
            "fzf|brew install fzf" \
            "vivid|brew install vivid" \
            "bdcli|brew install betterdiscord/tap/bdcli" \
            "eza|brew install eza" \
            "duckdb|brew install duckdb" \
            "rich|brew install rich-cli" \
            "mediainfo|brew install media-info" \
            "magick|brew install imagemagick"

        for tool_spec in $optional_tools
            set -l tool_parts (string split -m 1 "|" $tool_spec)
            command -q $tool_parts[1]; or set -a missing_tools (printf "%-9s %s" $tool_parts[1] $tool_parts[2])
        end

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
