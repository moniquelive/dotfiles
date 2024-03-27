set guioptions=aAce
" hlsearch underline
highlight Search guibg=black guifg=yellow gui=underline

set lines=45
set columns=120

if has('macmenu')
  macmenu &File.New\ Tab key=<D-T>
endif

if exists('g:GuiLoaded')
  GuiAdaptativeColor 1
  GuiAdaptativeFont 1
  GuiLinespace 1
  GuiTabline 0
  GuiScrollBar 1
  GuiFont JetBrains_Mono:h12
endif

" Right Click Context Menu (Copy-Cut-Paste)
nnoremap <silent><RightMouse> :call GuiShowContextMenu()<CR>
inoremap <silent><RightMouse> <Esc>:call GuiShowContextMenu()<CR>
xnoremap <silent><RightMouse> :call GuiShowContextMenu()<CR>gv
snoremap <silent><RightMouse> <C-G>:call GuiShowContextMenu()<CR>gv

if has('macunix')
  set guifont=JetBrains_Mono:h12
  set guifontwide=Symbols_Nerd_Font_Mono:h1000-em

  set transparency=1
  set macmeta
  set macligatures

  " CtrlP clone
  " CMD-t
  nnoremap <D-t> <leader>t
  inoremap <D-t> <ESC><leader>t

  " CMD-B
  nnoremap <D-B> <leader>b
  inoremap <D-B> <ESC><leader>b

  " SHIFT-CMD-F
  nnoremap <D-F> <leader>f
  inoremap <D-F> <ESC><leader>f

  " SHIFT-CMD-M
  nnoremap <D-M> <leader>m
  inoremap <D-M> <ESC><leader>m

  " CMD-V
  nnoremap <D-V> <c-r>+
  inoremap <D-V> <c-r>+
  cnoremap <D-V> <c-r>+

  " CMD-C
  nnoremap <D-C> <leader>y
  inoremap <D-C> <ESC><leader>y
  vnoremap <D-C> <ESC><leader>y

  " CPP make / makerun (for openframeworks)
  " autocmd FileType cpp nmap <D-b> :make -j Release<cr>
  " autocmd FileType cpp nmap <D-r> :make RunRelease<cr>
else
  set guifont=JetBrains\ Mono\ 12
endif
