function clean_broken_links --description "Remove broken symlinks from /usr/local/bin"
    set -l target /usr/local/bin
    set -l dry_run 0
    set -l use_sudo 0

    for arg in $argv
        switch $arg
            case -n --dry-run
                set dry_run 1
            case -s --sudo
                set use_sudo 1
            case -h --help
                echo "Usage: clean_broken_links [--dry-run] [--sudo]"
                return 0
            case '*'
                echo "Unknown option: $arg"
                echo "Usage: clean_broken_links [--dry-run] [--sudo]"
                return 1
        end
    end

    if not test -d $target
        echo "Directory not found: $target"
        return 1
    end

    set -l broken
    for link in (command find $target -maxdepth 1 -type l 2>/dev/null)
        if not test -e $link
            set -a broken $link
        end
    end

    if test (count $broken) -eq 0
        echo "No broken symlinks found in $target"
        return 0
    end

    echo "Broken symlinks:"
    printf '  %s\n' $broken

    if test $dry_run -eq 1
        echo "Dry run only. Re-run without --dry-run to remove them."
        return 0
    end

    if test $use_sudo -eq 1
        command sudo -v
        or return 1
    end

    set -l removed 0
    set -l failed 0
    for link in $broken
        if test $use_sudo -eq 1
            if command sudo rm -- $link
                set removed (math $removed + 1)
            else
                set failed (math $failed + 1)
            end
        else
            if command rm -- $link
                set removed (math $removed + 1)
            else
                set failed (math $failed + 1)
            end
        end
    end

    echo "Removed $removed broken symlink(s)."
    if test $failed -gt 0
        echo "Failed to remove $failed symlink(s)."
        return 1
    end
end
