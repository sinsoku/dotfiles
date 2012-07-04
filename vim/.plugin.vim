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
