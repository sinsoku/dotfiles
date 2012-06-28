#!/bin/sh

shell_path=$(cd $(dirname $0);pwd)

# git
ln -fs ${shell_path}/git/.gitconfig ~/
ln -fs ${shell_path}/git/.gitignore_global ~/
ln -fs ${shell_path}/git/gitignore ~/

# ruby
ln -fs ${shell_path}/ruby/.gemrc ~/
ln -fs ${shell_path}/ruby/.railsrc ~/
ln -fs ${shell_path}/ruby/rails_template ~/
ln -fs ${shell_path}/git/gitignore ${shell_path}/ruby/rails_template/
