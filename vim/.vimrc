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
set statusline=%<%f\ %m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%l,%c%V%8P
set hlsearch

" whitespaceEOL on highlight via. gunyara
highlight WhitespaceEOL ctermbg=red guibg=red
match WhitespaceEOL /\s\+$/
autocmd WinEnter * match WhitespaceEOL /\s\+$/

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
