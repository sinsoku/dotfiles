# Created by newuser for 5.0.5

# zsh-completions
fpath=(/usr/local/share/zsh-completions $fpath)

autoload -Uz compinit
compinit -u

# rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# nvm
source $(brew --prefix nvm)/nvm.sh

# alias
alias l="ls -G"
alias ll="ls -alG"
alias be="bundle exec"

# pyenv
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi

# prompt
autoload colors
colors
PROMPT="%{${fg[green]}%}%n%{${reset_color}%}@%{${fg[cyan]}%}%m%{${reset_color}%}: %{${fg[yellow]}%}%~%{${reset_color}%}
%# "

# prompt for vcs
autoload -Uz vcs_info
zstyle ':vcs_info:*' formats '(%s)-[%b]'
zstyle ':vcs_info:*' actionformats '(%s)-[%b|%a]'
precmd () {
    psvar=()
    LANG=en_US.UTF-8 vcs_info
    [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"
}
RPROMPT="%1(v|%F{green}%1v%f|)"
