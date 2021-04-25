#!/bin/sh

shell_path=$(cd $(dirname $0);pwd)

# zsh
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
# mkdir -p $(rbenv root)/plugins/
# ln -fs $(ghq root)/github.com/rbenv/rbenv-each $(rbenv root)/plugins/
# ln -fs $(ghq root)/github.com/rbenv/rbenv-default-gems $(rbenv root)/plugins/
# ln -fs $(ghq root)/github.com/amatsuda/gem-src $(rbenv root)/plugins/
ln -fs ${shell_path}/ruby/default-gems ~/.rbenv/

# vim
[ -d ~/.vim ] || mkdir ~/.vim
ln -fs ${shell_path}/vim/vimrc ~/.vim/
vim -c PlugInstall

# bin
ln -fs ${shell_path}/bin ~/

# refs: https://github.com/brianmario/mysql2/issues/1005#issuecomment-488432274
sudo installer -pkg /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg -target /
