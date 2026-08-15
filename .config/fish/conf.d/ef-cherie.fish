# Ef Cherie
set -l bg_main 190a0f
set -l bg_dim 291f26
set -l bg_alt 392a2f
set -l bg_region 232f3f
set -l fg_main d3cfcf
set -l fg_dim 808898
set -l fg_alt bf9cdf
set -l border 695960
set -l red ff7359
set -l green 60b444
set -l yellow e5b76f
set -l blue 8fa5f6
set -l magenta ef80bf
set -l magenta_faint cc9bcf
set -l cyan 8fbaef

set -g fish_color_normal $fg_main
set -g fish_color_command $magenta
set -g fish_color_keyword $magenta
set -g fish_color_quote $yellow
set -g fish_color_redirection $cyan
set -g fish_color_end $fg_dim
set -g fish_color_error $red
set -g fish_color_param $magenta_faint
set -g fish_color_comment $fg_dim
set -g fish_color_selection --background=$bg_region
set -g fish_color_search_match --background=$bg_alt
set -g fish_color_operator $fg_main
set -g fish_color_escape $cyan
set -g fish_color_autosuggestion $fg_dim
set -g fish_color_cwd $blue
set -g fish_color_user $yellow
set -g fish_color_host $cyan
set -g fish_color_host_remote $fg_alt
set -g fish_color_cancel $fg_main
set -g fish_color_valid_path

set -g fish_pager_color_progress $magenta
set -g fish_pager_color_background --background=$bg_dim
set -g fish_pager_color_prefix $cyan
set -g fish_pager_color_completion $fg_dim
set -g fish_pager_color_description $fg_dim
set -g fish_pager_color_secondary_background
set -g fish_pager_color_secondary_prefix
set -g fish_pager_color_secondary_completion
set -g fish_pager_color_secondary_description
set -g fish_pager_color_selected_background --background=$bg_alt
set -g fish_pager_color_selected_prefix $cyan
set -g fish_pager_color_selected_completion $fg_main
set -g fish_pager_color_selected_description $fg_main

set -g fish_color_subtle $fg_dim
set -g fish_color_text $fg_main
