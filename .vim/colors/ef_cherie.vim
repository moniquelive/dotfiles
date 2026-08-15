" Ef Cherie, ported from Protesilaos Stavrou's Ef themes.
hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'ef_cherie'
set background=dark

hi Normal guifg=#d3cfcf guibg=NONE ctermfg=252 ctermbg=NONE
hi Cursor guifg=#190a0f guibg=#ff5aaf
hi CursorLine guibg=#401f33
hi CursorLineNr guifg=#f470df guibg=NONE gui=bold
hi LineNr guifg=#808898 guibg=NONE
hi Visual guibg=#232f3f
hi Search guifg=#d3cfcf guibg=#8f5040
hi IncSearch guifg=#190a0f guibg=#ea9955 gui=bold
hi MatchParen guifg=#d3cfcf guibg=#3f5f75 gui=bold
hi StatusLine guifg=#ffcfdf guibg=#771a4f gui=bold
hi StatusLineNC guifg=#808898 guibg=#291f26
hi VertSplit guifg=#695960 guibg=NONE
hi Pmenu guifg=#d3cfcf guibg=#2a1019
hi PmenuSel guifg=#d3cfcf guibg=#4a1937 gui=bold
hi Folded guifg=#bf9cdf guibg=#291f26
hi SignColumn guibg=NONE
hi Directory guifg=#8fa5f6
hi Title guifg=#ff7359 gui=bold
hi ErrorMsg guifg=#ff656f guibg=#461017
hi WarningMsg guifg=#ea9955 guibg=#3a3004
hi MoreMsg guifg=#60b444
hi Question guifg=#f470df

hi Comment guifg=#bf9f8f gui=italic
hi Constant guifg=#ff78aa
hi String guifg=#e5b76f
hi Identifier guifg=#cc9bcf
hi Function guifg=#f59280
hi Statement guifg=#ef80bf
hi PreProc guifg=#8fbaef
hi Type guifg=#f470df
hi Special guifg=#ff7359
hi Underlined guifg=#df7fff gui=underline
hi Todo guifg=#ff656f guibg=#65102a gui=bold

hi DiffAdd guifg=#a0e0a0 guibg=#00351f
hi DiffChange guifg=#efef80 guibg=#363300
hi DiffDelete guifg=#ffbfbf guibg=#510c28
hi DiffText guifg=#efef80 guibg=#4a4a00 gui=bold

hi link Boolean Constant
hi link Character Constant
hi link Number Constant
hi link Float Number
hi link Conditional Statement
hi link Repeat Statement
hi link Label Statement
hi link Operator Statement
hi link Keyword Statement
hi link Exception Statement
hi link Include PreProc
hi link Define PreProc
hi link Macro PreProc
hi link PreCondit PreProc
hi link StorageClass Type
hi link Structure Type
hi link Typedef Type
hi link Tag Special
hi link SpecialChar Special
hi link Delimiter Special
hi link SpecialComment Special
hi link Debug Special
