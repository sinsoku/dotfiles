"encode.vimで内部エンコーディングと自動認識を設定する
source ~/.vim/encode.vim

" vundle
filetype off                   " required!

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required!
Bundle 'gmarik/vundle'

" My Bundles here:
source ~/bundles.vim

filetype plugin indent on     " required!

" vimdoc-ja
set helplang=ja

" 「日本語入力固定モード」切替キー
inoremap <silent> <C-j> <C-r>=IMState('FixMode')<CR>
" PythonによるIBus制御指定
let IM_CtrlIBusPython = 1

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

"preview interpreter's output(Tip #1244)
function! Ruby_eval_vsplit() range
    if &filetype == "ruby"
        let src = tempname()
        let dst = "RubyOutput"
        " put current buffer's content in a temp file
        silent execute ": " . a:firstline . "," . a:lastline . "w " . src
        " open the preview window
        silent execute ":pedit! " . dst
        " change to preview window
        wincmd P
        " set options
        setlocal buftype=nofile
        setlocal noswapfile
        setlocal syntax=none
        setlocal bufhidden=delete
        " replace current buffer with ruby's output
        silent execute ":%! ruby " . src . " 2>&1 "
        " change back to the source buffer
        wincmd p
    endif
endfunction
"<F5>でバッファのRubyスクリプトを実行し、結果をプレビュー表示
map <silent> <F5> :call Ruby_eval_vsplit()<CR>
map <silent> <S-F5> :pc<CR>

"preview rspec output
function! Rspec_eval_vsplit() range
    if &filetype == "ruby"
        let src = expand("%")
	echo src
        let dst = "RspecOutput"
        " open the preview window
        silent execute ":pedit! " . dst
        " change to preview window
        wincmd P
        " set options
        setlocal buftype=nofile
        setlocal noswapfile
        setlocal syntax=none
        setlocal bufhidden=delete
        " replace current buffer with nosetest's output
        silent execute ":%! rspec -f d --color " . src . " 2>&1"
        " change back to the source buffer
        wincmd p
    endif
endfunction

"<F6>でRspecを実行し、結果をプレビュー表示
" map <silent> <F6> :call Rspec_eval_vsplit()<CR>
"<S-F6>でプレビュー表示を閉じる
" map <silent> <S-F6> :pc<CR>

" プレビュー表示は色が付かないので、とりあえず実行するだけ
map <silent> <F6> :!rspec -f d --color %<CR>

"preview nosetests output
function! Nosetest(args) range
    set previewheight=18
    let src = expand("%")
    if src !~ "[Tt]est.*\.py$"
        let filepaths = split(src, "\\")
        let filepaths[-1] = "test_" . filepaths[-1]
        let src = expand("**/" . filepaths[-1])
    endif
    let dst = "NosetestOutput"
    " open the preview window
    silent execute ":pedit! " . dst
    " change to preview window
    wincmd P
    " set options
    setlocal buftype=nofile
    setlocal noswapfile
    setlocal syntax=none
    setlocal bufhidden=delete
    " replace current buffer with nosetest's output
    silent execute ":%! nosetests " . a:args . " " . src . " 2>&1"
    " change back to the source buffer
    wincmd p
    set previewheight=12
endfunction

"<F7>でnosetest -vを実行し、結果をプレビュー表示
map <silent> <F7> :call Nosetest("-v")<CR>
"<S-F7>でプレビュー表示を閉じる
map <silent> <S-F7> :silent exec ":pclose!"<CR>

" magic comment
function! MagicComment()
    let magic_comment = "# -*- coding: utf-8 -*-\n"
    let pos = getpos(".")
    call cursor(1, 0)
    execute ":normal i" . magic_comment
    call setpos(".", pos)
endfunction

map <silent> <F12> :call MagicComment()<CR>

" template
autocmd BufNewFile *.rb 0r ~/.vim/templates/rb.tpl
autocmd BufNewFile *.py 0r ~/.vim/templates/py.tpl

" RSpec syntac
function! RSpecSyntax()
  hi def link rubyRailsTestMethod Function
  syn keyword rubyRailsTestMethod describe context it its specify shared_examples_for it_should_behave_like before after around subject fixtures controller_name helper_name
  syn match rubyRailsTestMethod '\<let\>!\='
  syn keyword rubyRailsTestMethod violated pending expect double mock mock_model stub_model
  syn match rubyRailsTestMethod '\.\@<!\<stub\>!\@!'
endfunction
autocmd BufReadPost *_spec.rb call RSpecSyntax()
