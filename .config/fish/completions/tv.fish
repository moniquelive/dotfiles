# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_tv_global_optspecs
	string join \n s/source-command= ansi no-sort source-display= source-output= source-entry-delimiter= p/preview-command= preview-header= preview-footer= cache-preview preview-offset= no-preview hide-preview show-preview preview-border= preview-padding= preview-word-wrap hide-preview-scrollbar preview-size= i/input= input-header= input-prompt= input-position= input-border= input-padding= no-status-bar hide-status-bar show-status-bar results-border= results-padding= layout= no-remote hide-remote show-remote no-help-panel hide-help-panel show-help-panel ui-scale= height= width= inline t/tick-rate= watch= autocomplete-prompt= exact select-1 take-1 take-1-fast k/keybindings= expect= config-file= cable-dir= global-history h/help V/version
end

function __fish_tv_needs_command
	# Figure out if the current invocation already has a command.
	set -l cmd (commandline -opc)
	set -e cmd[1]
	argparse -s (__fish_tv_global_optspecs) -- $cmd 2>/dev/null
	or return
	if set -q argv[1]
		# Also print the command, so this can be used to figure out what it is.
		echo $argv[1]
		return 1
	end
	return 0
end

function __fish_tv_using_subcommand
	set -l cmd (__fish_tv_needs_command)
	test -z "$cmd"
	and return 1
	contains -- $cmd[1] $argv
end

complete -c tv -n "__fish_tv_needs_command" -s s -l source-command -d 'Source command to use for the current channel.' -r
complete -c tv -n "__fish_tv_needs_command" -l source-display -d 'Source display template to use for the current channel.' -r
complete -c tv -n "__fish_tv_needs_command" -l source-output -d 'Source output template to use for the current channel.' -r
complete -c tv -n "__fish_tv_needs_command" -l source-entry-delimiter -d 'The delimiter byte to use for splitting the source\'s command output into entries.' -r
complete -c tv -n "__fish_tv_needs_command" -s p -l preview-command -d 'Preview command to use for the current channel.' -r
complete -c tv -n "__fish_tv_needs_command" -l preview-header -d 'Preview header template' -r
complete -c tv -n "__fish_tv_needs_command" -l preview-footer -d 'Preview footer template' -r
complete -c tv -n "__fish_tv_needs_command" -l preview-offset -d 'A preview line number offset template to use to scroll the preview to for each entry.' -r
complete -c tv -n "__fish_tv_needs_command" -l preview-border -d 'Sets the preview panel border type.' -r -f -a "none\t''
plain\t''
rounded\t''
thick\t''"
complete -c tv -n "__fish_tv_needs_command" -l preview-padding -d 'Sets the preview panel padding.' -r
complete -c tv -n "__fish_tv_needs_command" -l preview-size -d 'Percentage of the screen to allocate to the preview panel (1-99).' -r
complete -c tv -n "__fish_tv_needs_command" -s i -l input -d 'Input text to pass to the channel to prefill the prompt.' -r
complete -c tv -n "__fish_tv_needs_command" -l input-header -d 'Input field header template.' -r
complete -c tv -n "__fish_tv_needs_command" -l input-prompt -d 'Input prompt string' -r
complete -c tv -n "__fish_tv_needs_command" -l input-position -d 'Input bar position.' -r -f -a "top\t''
bottom\t''"
complete -c tv -n "__fish_tv_needs_command" -l input-border -d 'Sets the input panel border type.' -r -f -a "none\t''
plain\t''
rounded\t''
thick\t''"
complete -c tv -n "__fish_tv_needs_command" -l input-padding -d 'Sets the input panel padding.' -r
complete -c tv -n "__fish_tv_needs_command" -l results-border -d 'Sets the results panel border type.' -r -f -a "none\t''
plain\t''
rounded\t''
thick\t''"
complete -c tv -n "__fish_tv_needs_command" -l results-padding -d 'Sets the results panel padding.' -r
complete -c tv -n "__fish_tv_needs_command" -l layout -d 'Layout orientation for the UI.' -r -f -a "landscape\t''
portrait\t''"
complete -c tv -n "__fish_tv_needs_command" -l ui-scale -d 'Change the display size in relation to the available area.' -r
complete -c tv -n "__fish_tv_needs_command" -l height -d 'Height in lines for non-fullscreen mode.' -r
complete -c tv -n "__fish_tv_needs_command" -l width -d 'Width in columns for non-fullscreen mode.' -r
complete -c tv -n "__fish_tv_needs_command" -s t -l tick-rate -d 'The application\'s tick rate.' -r
complete -c tv -n "__fish_tv_needs_command" -l watch -d 'Watch mode: reload the source command every N seconds.' -r
complete -c tv -n "__fish_tv_needs_command" -l autocomplete-prompt -d 'Try to guess the channel from the provided input prompt.' -r
complete -c tv -n "__fish_tv_needs_command" -s k -l keybindings -d 'Keybindings to override the default keybindings.' -r
complete -c tv -n "__fish_tv_needs_command" -l expect -d 'Keys that can be used to confirm the current selection in addition to the default ones (typically `enter`).' -r
complete -c tv -n "__fish_tv_needs_command" -l config-file -d 'Provide a custom configuration file to use.' -r
complete -c tv -n "__fish_tv_needs_command" -l cable-dir -d 'Provide a custom cable directory to use.' -r
complete -c tv -n "__fish_tv_needs_command" -l ansi -d 'Whether tv should extract and parse ANSI style codes from the source command output.'
complete -c tv -n "__fish_tv_needs_command" -l no-sort -d 'Disable automatic sorting of entries based on match quality.'
complete -c tv -n "__fish_tv_needs_command" -l cache-preview -d 'Whether to cache the preview command output for each entry.'
complete -c tv -n "__fish_tv_needs_command" -l no-preview -d 'Disable the preview panel entirely on startup.'
complete -c tv -n "__fish_tv_needs_command" -l hide-preview -d 'Hide the preview panel on startup (only works if feature is enabled).'
complete -c tv -n "__fish_tv_needs_command" -l show-preview -d 'Show the preview panel on startup (only works if feature is enabled).'
complete -c tv -n "__fish_tv_needs_command" -l preview-word-wrap -d 'Enables preview panel word wrap.'
complete -c tv -n "__fish_tv_needs_command" -l hide-preview-scrollbar -d 'Hide preview panel scrollbar.'
complete -c tv -n "__fish_tv_needs_command" -l no-status-bar -d 'Disable the status bar entirely on startup.'
complete -c tv -n "__fish_tv_needs_command" -l hide-status-bar -d 'Hide the status bar on startup (only works if feature is enabled).'
complete -c tv -n "__fish_tv_needs_command" -l show-status-bar -d 'Show the status bar on startup (only works if feature is enabled).'
complete -c tv -n "__fish_tv_needs_command" -l no-remote -d 'Disable the remote control.'
complete -c tv -n "__fish_tv_needs_command" -l hide-remote -d 'Hide the remote control on startup (only works if feature is enabled).'
complete -c tv -n "__fish_tv_needs_command" -l show-remote -d 'Show the remote control on startup (only works if feature is enabled).'
complete -c tv -n "__fish_tv_needs_command" -l no-help-panel -d 'Disable the help panel entirely on startup.'
complete -c tv -n "__fish_tv_needs_command" -l hide-help-panel -d 'Hide the help panel on startup (only works if feature is enabled).'
complete -c tv -n "__fish_tv_needs_command" -l show-help-panel -d 'Show the help panel on startup (only works if feature is enabled).'
complete -c tv -n "__fish_tv_needs_command" -l inline -d 'Use all available empty space at the bottom of the terminal as an inline interface.'
complete -c tv -n "__fish_tv_needs_command" -l exact -d 'Use substring matching instead of fuzzy matching.'
complete -c tv -n "__fish_tv_needs_command" -l select-1 -d 'Automatically select and output the first entry if there is only one entry.'
complete -c tv -n "__fish_tv_needs_command" -l take-1 -d 'Take the first entry from the list after the channel has finished loading.'
complete -c tv -n "__fish_tv_needs_command" -l take-1-fast -d 'Take the first entry from the list as soon as it becomes available.'
complete -c tv -n "__fish_tv_needs_command" -l global-history -d 'Use global history instead of channel-specific history.'
complete -c tv -n "__fish_tv_needs_command" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c tv -n "__fish_tv_needs_command" -s V -l version -d 'Print version'
complete -c tv -n "__fish_tv_needs_command" -a "list-channels" -d 'Lists the available channels'
complete -c tv -n "__fish_tv_needs_command" -a "init" -d 'Initializes shell completion ("tv init zsh")'
complete -c tv -n "__fish_tv_needs_command" -a "completions" -d 'Generates standard shell tab-completion scripts for tv\'s various subcommands'
complete -c tv -n "__fish_tv_needs_command" -a "update-channels" -d 'Downloads the latest collection of channel prototypes from github and saves them to the local configuration directory'
complete -c tv -n "__fish_tv_needs_command" -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c tv -n "__fish_tv_using_subcommand list-channels" -s h -l help -d 'Print help'
complete -c tv -n "__fish_tv_using_subcommand init" -s h -l help -d 'Print help'
complete -c tv -n "__fish_tv_using_subcommand completions" -s h -l help -d 'Print help'
complete -c tv -n "__fish_tv_using_subcommand update-channels" -l force -d 'Force update on unsupported and already existing channels'
complete -c tv -n "__fish_tv_using_subcommand update-channels" -s h -l help -d 'Print help'
complete -c tv -n "__fish_tv_using_subcommand help; and not __fish_seen_subcommand_from list-channels init completions update-channels help" -f -a "list-channels" -d 'Lists the available channels'
complete -c tv -n "__fish_tv_using_subcommand help; and not __fish_seen_subcommand_from list-channels init completions update-channels help" -f -a "init" -d 'Initializes shell completion ("tv init zsh")'
complete -c tv -n "__fish_tv_using_subcommand help; and not __fish_seen_subcommand_from list-channels init completions update-channels help" -f -a "completions" -d 'Generates standard shell tab-completion scripts for tv\'s various subcommands'
complete -c tv -n "__fish_tv_using_subcommand help; and not __fish_seen_subcommand_from list-channels init completions update-channels help" -f -a "update-channels" -d 'Downloads the latest collection of channel prototypes from github and saves them to the local configuration directory'
complete -c tv -n "__fish_tv_using_subcommand help; and not __fish_seen_subcommand_from list-channels init completions update-channels help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
