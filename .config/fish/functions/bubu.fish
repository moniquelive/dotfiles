function __bubu_mise_update
    mise plugins update
    and mise upgrade --bump
    and mise prune
end

function bubu
    switch (uname -s)
        case Darwin
            set -lx HOMEBREW_NO_ASK 1
            brew update
            and brew upgrade --greedy-auto-updates
            and brew autoremove
            and brew cleanup
        case FreeBSD
            sudo pkg update
            and sudo pkg upgrade -y
        case Linux
            if test -f /etc/arch-release
                yay -Syuu --noconfirm --devel --needed
            else if test -f /etc/fedora-release
                sudo dnf upgrade --refresh -y
            else
                echo "bubu: unsupported Linux distribution" >&2
                return 1
            end
        case '*'
            echo "bubu: unsupported operating system" >&2
            return 1
    end
    and __bubu_mise_update
end
