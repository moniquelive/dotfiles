function __bubu_mise_update
    mise p up
    and mise prune
    and mise up --bump
    and mise up
end

function bubu
    switch (uname -s)
        case Darwin
            set -lx HOMEBREW_NO_ASK 1
            brew update
            and brew outdated
            and brew upgrade
            and brew upgrade --greedy
            and brew upgrade --cask --greedy
            and brew cleanup
            and brew autoremove
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
