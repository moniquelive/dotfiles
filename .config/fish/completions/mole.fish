# Completions for mole
complete -f -c mole -n "__fish_mole_no_subcommand" -a clean -d "Free up disk space"
complete -f -c mole -n "__fish_mole_no_subcommand" -a uninstall -d "Remove apps completely"
complete -f -c mole -n "__fish_mole_no_subcommand" -a optimize -d "Refresh caches and services"
complete -f -c mole -n "__fish_mole_no_subcommand" -a analyze -d "Explore disk usage"
complete -f -c mole -n "__fish_mole_no_subcommand" -a status -d "Monitor system health"
complete -f -c mole -n "__fish_mole_no_subcommand" -a history -d "Review cleanup activity"
complete -f -c mole -n "__fish_mole_no_subcommand" -a purge -d "Remove old project artifacts"
complete -f -c mole -n "__fish_mole_no_subcommand" -a installer -d "Find and remove installer files"
complete -f -c mole -n "__fish_mole_no_subcommand" -a touchid -d "Configure Touch ID for sudo"
complete -f -c mole -n "__fish_mole_no_subcommand" -a completion -d "Setup shell tab completion"
complete -f -c mole -n "__fish_mole_no_subcommand" -a update -d "Update to latest version"
complete -f -c mole -n "__fish_mole_no_subcommand" -a remove -d "Remove Mole from system"
complete -f -c mole -n "__fish_mole_no_subcommand" -a help -d "Show help"
complete -f -c mole -n "__fish_mole_no_subcommand" -a version -d "Show version"

complete -f -c mole -n "__fish_seen_subcommand_from clean" -l dry-run -s n -d "Preview cleanup without making changes"
complete -c mole -n "__fish_seen_subcommand_from clean" -l external -r -a "(__fish_complete_directories)" -d "Clean OS metadata from an external volume"
complete -f -c mole -n "__fish_seen_subcommand_from clean" -l whitelist -d "Manage protected paths"
complete -f -c mole -n "__fish_seen_subcommand_from clean" -l debug -d "Show detailed logs"
complete -f -c mole -n "__fish_seen_subcommand_from clean" -l help -s h -d "Show help"
complete -f -c mole -n "__fish_seen_subcommand_from analyze analyse" -l json -d "Output analysis as JSON"
complete -f -c mole -n "__fish_seen_subcommand_from analyze analyse" -l help -s h -d "Show help"
complete -c mole -n "__fish_seen_subcommand_from analyze analyse; and not __fish_seen_argument -l json -l help -s h" -a "(__fish_complete_directories)" -d "Path to analyze"
complete -f -c mole -n "__fish_seen_subcommand_from history" -l json -d "Output history as JSON"
complete -f -c mole -n "__fish_seen_subcommand_from history" -l limit -r -d "Limit recent entries"
complete -f -c mole -n "__fish_seen_subcommand_from history" -l help -s h -d "Show help"
complete -f -c mole -n "__fish_seen_subcommand_from purge" -l paths -d "Edit custom scan directories"
complete -f -c mole -n "__fish_seen_subcommand_from purge" -l dry-run -s n -d "Preview purge actions without making changes"
complete -f -c mole -n "__fish_seen_subcommand_from purge" -l include-empty -d "Show zero-size project artifact directories"
complete -f -c mole -n "__fish_seen_subcommand_from purge" -l debug -d "Show detailed logs"
complete -f -c mole -n "__fish_seen_subcommand_from purge" -l help -s h -d "Show help"

complete -f -c mole -n "not __fish_mole_no_subcommand" -a bash -d "generate bash completion" -n "__fish_see_subcommand_path completion"
complete -f -c mole -n "not __fish_mole_no_subcommand" -a zsh -d "generate zsh completion" -n "__fish_see_subcommand_path completion"
complete -f -c mole -n "not __fish_mole_no_subcommand" -a fish -d "generate fish completion" -n "__fish_see_subcommand_path completion"

# Completions for mo (alias)
complete -f -c mo -n "__fish_mole_no_subcommand" -a clean -d "Free up disk space"
complete -f -c mo -n "__fish_mole_no_subcommand" -a uninstall -d "Remove apps completely"
complete -f -c mo -n "__fish_mole_no_subcommand" -a optimize -d "Refresh caches and services"
complete -f -c mo -n "__fish_mole_no_subcommand" -a analyze -d "Explore disk usage"
complete -f -c mo -n "__fish_mole_no_subcommand" -a status -d "Monitor system health"
complete -f -c mo -n "__fish_mole_no_subcommand" -a history -d "Review cleanup activity"
complete -f -c mo -n "__fish_mole_no_subcommand" -a purge -d "Remove old project artifacts"
complete -f -c mo -n "__fish_mole_no_subcommand" -a installer -d "Find and remove installer files"
complete -f -c mo -n "__fish_mole_no_subcommand" -a touchid -d "Configure Touch ID for sudo"
complete -f -c mo -n "__fish_mole_no_subcommand" -a completion -d "Setup shell tab completion"
complete -f -c mo -n "__fish_mole_no_subcommand" -a update -d "Update to latest version"
complete -f -c mo -n "__fish_mole_no_subcommand" -a remove -d "Remove Mole from system"
complete -f -c mo -n "__fish_mole_no_subcommand" -a help -d "Show help"
complete -f -c mo -n "__fish_mole_no_subcommand" -a version -d "Show version"

complete -f -c mo -n "__fish_seen_subcommand_from clean" -l dry-run -s n -d "Preview cleanup without making changes"
complete -c mo -n "__fish_seen_subcommand_from clean" -l external -r -a "(__fish_complete_directories)" -d "Clean OS metadata from an external volume"
complete -f -c mo -n "__fish_seen_subcommand_from clean" -l whitelist -d "Manage protected paths"
complete -f -c mo -n "__fish_seen_subcommand_from clean" -l debug -d "Show detailed logs"
complete -f -c mo -n "__fish_seen_subcommand_from clean" -l help -s h -d "Show help"
complete -f -c mo -n "__fish_seen_subcommand_from analyze analyse" -l json -d "Output analysis as JSON"
complete -f -c mo -n "__fish_seen_subcommand_from analyze analyse" -l help -s h -d "Show help"
complete -c mo -n "__fish_seen_subcommand_from analyze analyse; and not __fish_seen_argument -l json -l help -s h" -a "(__fish_complete_directories)" -d "Path to analyze"
complete -f -c mo -n "__fish_seen_subcommand_from history" -l json -d "Output history as JSON"
complete -f -c mo -n "__fish_seen_subcommand_from history" -l limit -r -d "Limit recent entries"
complete -f -c mo -n "__fish_seen_subcommand_from history" -l help -s h -d "Show help"
complete -f -c mo -n "__fish_seen_subcommand_from purge" -l paths -d "Edit custom scan directories"
complete -f -c mo -n "__fish_seen_subcommand_from purge" -l dry-run -s n -d "Preview purge actions without making changes"
complete -f -c mo -n "__fish_seen_subcommand_from purge" -l include-empty -d "Show zero-size project artifact directories"
complete -f -c mo -n "__fish_seen_subcommand_from purge" -l debug -d "Show detailed logs"
complete -f -c mo -n "__fish_seen_subcommand_from purge" -l help -s h -d "Show help"

complete -f -c mo -n "not __fish_mole_no_subcommand" -a bash -d "generate bash completion" -n "__fish_see_subcommand_path completion"
complete -f -c mo -n "not __fish_mole_no_subcommand" -a zsh -d "generate zsh completion" -n "__fish_see_subcommand_path completion"
complete -f -c mo -n "not __fish_mole_no_subcommand" -a fish -d "generate fish completion" -n "__fish_see_subcommand_path completion"

function __fish_mole_no_subcommand
    for i in (commandline -opc)
        if contains -- $i clean uninstall optimize analyze status history purge installer touchid completion update remove help version
            return 1
        end
    end
    return 0
end

function __fish_see_subcommand_path
    string match -q -- "completion" (commandline -opc)[1]
end
