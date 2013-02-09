" Align
let g:Align_xstrlen = 3      " for japanese string
let g:DrChipTopLvlMenu = ' ' " remove 'DrChip' menu

" visualstar
nnoremap * *N
nnoremap # #N
map * <Plug>(visualstar-*)N
map # <Plug>(visualstar-#)N

" vim-textmanip
vmap <C-j> <Plug>(textmanip-move-down)
vmap <C-k> <Plug>(textmanip-move-up)
vmap <C-h> <Plug>(textmanip-move-left)
vmap <C-l> <Plug>(textmanip-move-right)
vmap <C-d> <Plug>(textmanip-duplicate-down) " copy selected lines

" quickrun
let g:quickrun_config = {}
let g:quickrun_config['ruby.rspec'] = {'runner': 'shell', 'command': 'rspec', 'args': "-l %{line('.')}" }
augroup RSpec
  autocmd!
  autocmd BufWinEnter,BufNewFile *_spec.rb set filetype=ruby.rspec
augroup END

" taglist
set tags=tags

" powerline
let g:Powerline_symbols = 'fancy'
set t_Co=256
let g:Powerline_colorscheme = 'bgnone'

" source ~/.neocomplcache.vim
