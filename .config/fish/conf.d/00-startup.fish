# Homebrew also ships a vendor activation hook; config.fish owns activation.
set -gx MISE_FISH_AUTO_ACTIVATE 0

# Do not let paths persisted on another OS trigger slow automount lookups.
set -l foreign_home
if string match -q '/Users/*' -- $HOME
    set foreign_home /home/$USER
else if string match -q '/home/*' -- $HOME
    set foreign_home /Users/$USER
end

if set -q foreign_home[1]
    for path_var in PATH __MISE_ORIG_PATH
        set -q $path_var; or continue
        set -l clean_path
        for dir in $$path_var
            string match -q "$foreign_home/*" -- $dir; or set -a clean_path $dir
        end
        set -gx $path_var $clean_path
    end
end
