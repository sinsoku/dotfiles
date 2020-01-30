# zmodload zsh/zprof && zprof

export PATH=$HOME/bin:$HOME/.cargo/bin:$PATH

# Address issues installing on macOS Catalina
#
# ref: https://github.com/brianmario/mysql2/pull/1051
export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/opt/openssl/lib/

export HISTFILE=$HOME/.zsh_history
export HISTSIZE=1000
export SAVEHIST=10000
