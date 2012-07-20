#!/bin/sh

shell_path=$(cd $(dirname $0);pwd)

# bash
ln -fs ${shell_path}/bash/.bashrc ~/

# vim
ln -fs ${shell_path}/vim/.vim ~/
ln -fs ${shell_path}/vim/.vimrc ~/
ln -fs ${shell_path}/vim/.basic.vim ~/
ln -fs ${shell_path}/vim/.colors.vim ~/
ln -fs ${shell_path}/vim/.encode.vim ~/
ln -fs ${shell_path}/vim/.plugin.vim ~/
ln -fs ${shell_path}/vim/.vundle.vim ~/
ln -fs ${shell_path}/vim/.neocomplcache.vim ~/

# git
ln -fs ${shell_path}/git/.gitconfig ~/
ln -fs ${shell_path}/git/.gitignore_global ~/
ln -fs ${shell_path}/git/gitignore ~/

# ruby
ln -fs ${shell_path}/ruby/.gemrc ~/
ln -fs ${shell_path}/ruby/.pryrc ~/
ln -fs ${shell_path}/ruby/.rspec ~/
ln -fs ${shell_path}/ruby/.railsrc ~/
ln -fs ${shell_path}/ruby/rails_template ~/
ln -fs ${shell_path}/git/gitignore ${shell_path}/ruby/rails_template/
