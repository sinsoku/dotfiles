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
zplug "plugins/bundler", from:oh-my-zsh
zplug "plugins/osx", from:oh-my-zsh
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "b4b4r07/enhancd", use:init.sh

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
eval "$(rbenv init -)"

# nvm
export NVM_DIR="$HOME/.nvm"
. "/usr/local/opt/nvm/nvm.sh"

autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# direnv
eval "$(direnv hook zsh)"

# travis gem
[ -f ~/.travis/travis.sh ] && source ~/.travis/travis.sh

# enhancd
export ENHANCD_FILTER=peco
