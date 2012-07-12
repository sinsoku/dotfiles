source ~/.encode.vim
source ~/.vundle.vim
source ~/.plugin.vim
source ~/.colors.vim

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

" auto-mkdir
augroup vimrc-auto-mkdir  " {{{
  autocmd!
  autocmd BufWritePre * call s:auto_mkdir(expand('<afile>:p:h'))
  function! s:auto_mkdir(dir)  " {{{
    if !isdirectory(a:dir)
      call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
    endif
  endfunction  " }}}
augroup END  " }}}
