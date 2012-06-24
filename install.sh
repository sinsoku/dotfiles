#!/bin/sh

shell_path=$(cd $(dirname $0);pwd)

ln -s ${shell_path}/git/.gitconfig ~/
ln -s ${shell_path}/git/.gitignore_global ~/
