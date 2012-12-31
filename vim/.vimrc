source ~/.encode.vim
source ~/.basic.vim
source ~/.vundle.vim
source ~/.plugin.vim
source ~/.colors.vim

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

" magic comment
function! MagicComment()
  let magic_comment = "# -*- coding: utf-8 -*-"
  call append(0, magic_comment)
endfunction
nnoremap <Space>m :call MagicComment()<Enter>
