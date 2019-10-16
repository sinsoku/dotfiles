# zmodload zsh/zprof && zprof

export PATH=$HOME/bin:$PATH

# Address issues installing on macOS Catalina
#
# ref: https://github.com/brianmario/mysql2/pull/1051
export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/opt/openssl/lib/
