# env
export EDITOR=vim

# zplug
export ZPLUG_HOME=$(brew --prefix)/opt/zplug
source $ZPLUG_HOME/init.zsh

# theme
zplug mafredri/zsh-async, from:github

# plugins
zplug "b4b4r07/emoji-cli"
zplug "mollifier/cd-gitroot"
zplug "plugins/bundler", from:oh-my-zsh
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "b4b4r07/enhancd", at: "b5bfe28a285d028e0a027094844d0df597146bae", use:init.sh

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
alias dc-build="docker compose build"
alias dc-up="docker compose up"
alias dc-down="docker compose down"
alias dc-run="docker compose run"
alias dc-exec="docker compose exec"

# colors
autoload -Uz colors
colors

# mise
eval "$(mise activate zsh)"

# direnv
eval "$(direnv hook zsh)"

# starship
eval "$(starship init zsh)"

# aws-vault
eval "$(aws-vault --completion-script-zsh)"

# enhancd
export ENHANCD_FILTER=peco

# zprof
if (which zprof > /dev/null 2>&1) ;then
  zprof
fi

# history
setopt hist_ignore_dups
setopt share_history

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$(brew --prefix)/share/zsh/site-functions:$FPATH

  autoload -Uz compinit
  compinit
fi

# Laravel
alias sail='[ -f sail ] && bash sail || bash vendor/bin/sail'

alias cd-ghq='cd $(ghq list -p | peco)'

export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="/opt/homebrew/opt/mysql@8.0/bin:$PATH"

export GPG_TTY=$(tty)

if [ -z "$SSH_AUTH_SOCK" ]; then
   # Check for a currently running instance of the agent
   RUNNING_AGENT="`ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]'`"
   if [ "$RUNNING_AGENT" = "0" ]; then
        # Launch a new instance of the agent
        ssh-agent -s &> $HOME/.ssh/ssh-agent
   fi
   eval `cat $HOME/.ssh/ssh-agent` > /dev/null
   ssh-add 2> /dev/null
fi
