#!/bin/sh

shell_path=$(cd $(dirname $0);pwd)

# zsh
ln -fs ${shell_path}/zsh/.zprofile ~/
ln -fs ${shell_path}/zsh/.zshrc ~/
ln -fs ${shell_path}/zsh/.zshenv ~/

# git
ln -fs ${shell_path}/git/.gitconfig ~/
ln -fs ${shell_path}/git/.gitignore_global ~/

# ruby
ln -fs ${shell_path}/ruby/.gemrc ~/
ln -fs ${shell_path}/ruby/.railsrc ~/
ln -fs ${shell_path}/ruby/.rspec ~/

# rbenv
[ -d ~/.rbenv ] || mkdir ~/.rbenv
mkdir -p $(rbenv root)/plugins/
ln -fs $(ghq root)/github.com/rbenv/rbenv-each $(rbenv root)/plugins/
ln -fs $(ghq root)/github.com/rbenv/rbenv-default-gems $(rbenv root)/plugins/
# ln -fs $(ghq root)/github.com/amatsuda/gem-src $(rbenv root)/plugins/
ln -fs ${shell_path}/ruby/default-gems ~/.rbenv/

# vim
[ -d ~/.vim ] || mkdir ~/.vim
ln -fs ${shell_path}/vim/vimrc ~/.vim/
[ -d ~/.vim/autoload/plug.vim ] || curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim -c PlugInstall

# bin
ln -fs ${shell_path}/bin ~/
