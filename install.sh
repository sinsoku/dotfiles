#!/bin/sh

shell_path=$(cd $(dirname $0);pwd)

# git
ln -s ${shell_path}/git/.gitconfig ~/
ln -s ${shell_path}/git/.gitignore_global ~/

# ruby
ln -s ${shell_path}/ruby/.railsrc ~/
ln -s ${shell_path}/ruby/rails_template ~/
