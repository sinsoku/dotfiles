# env
export EDITOR=vim

# zplug
export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

# theme
zplug mafredri/zsh-async, from:github

# plugins
zplug "b4b4r07/emoji-cli"
zplug "mollifier/cd-gitroot"
zplug "plugins/bundler", from:oh-my-zsh
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
zplug load

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
alias aws-whoami="aws sts get-caller-identity --output text --query Arn"

# colors
autoload -Uz colors
colors

# rbenv
eval "$(rbenv init -)"

# nodebrew
export PATH=$HOME/.nodebrew/current/bin:$PATH

# direnv
eval "$(direnv hook zsh)"

# starship
eval "$(starship init zsh)"

# aws-vault
eval "$(aws-vault --completion-script-zsh)"

# travis gem
[ -f ~/.travis/travis.sh ] && source ~/.travis/travis.sh

# enhancd
export ENHANCD_FILTER=peco

# zprof
if (which zprof > /dev/null 2>&1) ;then
  zprof
fi

# history
setopt hist_ignore_dups
setopt share_history
