#!/bin/sh

shell_path=$(cd $(dirname $0);pwd)

# zsh
ln -fs ${shell_path}/zsh/.zshrc ~/

# git
ln -fs ${shell_path}/git/.gitconfig ~/
ln -fs ${shell_path}/git/.gitignore_global ~/

# ruby
ln -fs ${shell_path}/ruby/.gemrc ~/
ln -fs ${shell_path}/ruby/.railsrc ~/
ln -fs ${shell_path}/ruby/.rspec ~/

# rbenv
[ -d ~/.rbenv ] || mkdir ~/.rbenv
ln -fs ${shell_path}/ruby/default-gems ~/.rbenv/

# vim
[ -d ~/.vim ] || mkdir ~/.vim
ln -fs ${shell_path}/vim/vimrc ~/.vim/
vim -c PlugInstall
