" vimdoc-ja
set helplang=ja

" filetype plugin
set nocompatible
syntax on
filetype on
filetype indent on
filetype plugin on

set number
set nowrap

set ruler
set wildmenu
set foldlevel=0
set clipboard+=unnamed
set laststatus=2
set hlsearch
set showcmd
set showmode
set noswapfile
set autoread
set display=uhex
set autoindent
set smartindent
set cindent
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=0
set backspace=indent,eol,start

nnoremap <Space>. :<C-u>edit $MYVIMRC<Enter>
nnoremap <Space>s. :<C-u>source $MYVIMRC<Enter>

nnoremap <C-h> :<C-u>help<Space><C-r><C-w><Enter>
