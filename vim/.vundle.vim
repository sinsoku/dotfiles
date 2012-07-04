set nocompatible               " be iMproved
filetype off                   " required!

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required!
Bundle 'gmarik/vundle'

" My Bundles here:
"
" original repos on github
" Bundle 'Lokaltog/vim-easymotion'
Bundle 'fuenor/vim-statusline'
Bundle 'kana/vim-textobj-fold'
Bundle 'kana/vim-textobj-indent'
Bundle 'kana/vim-textobj-lastpat'
Bundle 'kana/vim-textobj-user'
Bundle 'kchmck/vim-coffee-script'
" Bundle 'koron/chalice'
" Bundle 'mattn/gist-vim'
" Bundle 'motemen/git-vim'
" Bundle 'rstacruz/sparkup', {'rtp': 'vim/'}
Bundle 'Shougo/vimproc'
Bundle 't9md/vim-textmanip'
" Bundle 'taku-o/vim-toggle'
Bundle 'thinca/vim-quickrun'
Bundle 'thinca/vim-visualstar'
Bundle 'timcharper/textile.vim'
Bundle 'tomtom/tcomment_vim'
" Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-haml'
" Bundle 'tpope/vim-repeat'
" Bundle 'tpope/vim-speeddating'
Bundle 'tpope/vim-endwise'
Bundle 'tpope/vim-surround'
" Bundle 'ynkdir/vim-funlib'

" ruby
Bundle 'vim-ruby/vim-ruby'
Bundle 'tpope/vim-rails'

" vim-scripts repos
Bundle 'Align'
" Bundle 'FuzzyFinder'
" Bundle 'L9'
Bundle 'yaml.vim'
Bundle 'matchit.zip'

" non github repos
" Bundle 'git://git.wincent.com/command-t.git'

filetype plugin indent on     " required!
"
" Brief help
" :BundleList          - list configured bundles
" :BundleInstall(!)    - install(update) bundles
" :BundleSearch(!) foo - search(or refresh cache first) for foo
" :BundleClean(!)      - confirm(or auto-approve) removal of unused bundles
"
" see :h vundle for more details or wiki for FAQ
" NOTE: comments after Bundle command are not allowed..


