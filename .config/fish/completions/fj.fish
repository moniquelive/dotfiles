if command -q fj
    fj completion fish 2>/dev/null \
        | string match -v 'Could not find keys file. Creating a new file.' \
        | source
end
