# env
export EDITOR=vim

# zplug
export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

# theme
zplug 'themes/sorin', from:oh-my-zsh

# plugins
zplug "b4b4r07/emoji-cli"
zplug "mollifier/cd-gitroot"
zplug "mrowa44/emojify", as:command
zplug "plugins/bundler", from:oh-my-zsh
zplug "plugins/osx", from:oh-my-zsh

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

# Then, source plugins and add commands to $PATH
zplug load --verbose

# keymaps
bindkey -e # emacs
bindkey "^Xe" emoji::cli

# load cd-gitroot
fpath=($ZPLUG_HOME/repos/mollifier/cd-gitroot(N-/) $fpath)
autoload -Uz cd-gitroot

# alias
alias l="ls -G"
alias ll="ls -alG"
alias vi="vim"

# colors
autoload -Uz colors
colors

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
