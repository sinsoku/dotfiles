" colorscheme
" set background=dark
" colorscheme solarized

colorscheme desert-warm-256

" whitespaceEOL on highlight
highlight WhitespaceEOL ctermbg=red guibg=red
autocmd BufWinEnter * let w:m1 = matchadd("WhitespaceEOL", '\s\+$')
autocmd WinEnter * let w:m1 = matchadd("WhitespaceEOL", '\s\+$')

" tabstring on highlight
highlight TabString ctermbg=red guibg=red
autocmd BufWinEnter * let w:m2 = matchadd("TabString", '^\t+')
autocmd WinEnter * let w:m2 = matchadd("TabString", '^\t+')

" JpSpace on underline
highlight ZenkakuSpace cterm=underline ctermbg=red guibg=red
autocmd BufWinEnter * let w:m3 = matchadd("ZenkakuSpace", '　')
autocmd WinEnter * let w:m3 = matchadd("ZenkakuSpace", '　')

