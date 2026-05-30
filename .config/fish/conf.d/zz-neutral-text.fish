# Keep Rose Pine accents, but make regular shell text neutral gray.
set -l neutral_text d0d0d0

set -g fish_color_normal $neutral_text
set -g fish_color_command $neutral_text
set -g fish_color_param $neutral_text
set -g fish_color_operator $neutral_text
set -g fish_color_cancel $neutral_text
set -g fish_color_text $neutral_text

# Carapace completions in fish are rendered by fish's pager colors.
set -g fish_pager_color_completion $neutral_text
set -g fish_pager_color_description 908caa
set -g fish_pager_color_selected_completion $neutral_text
set -g fish_pager_color_selected_description $neutral_text
