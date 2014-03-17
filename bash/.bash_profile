if [ -f /opt/boxen/homebrew/etc/bash_completion ]; then
  . /opt/boxen/homebrew/etc/bash_completion
fi

if [ -n "$BASH_VERSION" ]; then
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi
