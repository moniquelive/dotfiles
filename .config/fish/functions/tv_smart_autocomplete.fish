function tv_smart_autocomplete
    functions -e tv_smart_autocomplete tv_shell_history __tv_parse_commandline
    tv init fish | source
    tv_smart_autocomplete
end
