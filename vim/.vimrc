source ~/.encode.vim
source ~/.vundle.vim
source ~/.plugin.vim

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

" ポップアップメニューの色設定
hi Pmenu ctermbg=5

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
