# dotfiles

## Environment

* MacBook 2016

## brew

http://brew.sh/

```
$ brew install $(cat brew/list)
```

## brew cask

https://caskroom.github.io/

```
$ brew tap caskroom/cask
$ brew install $(cat brew/cask_list)
```

## Ruby

```
$ git clone https://github.com/rbenv/rbenv.git ~/.rbenv
$ git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
$ git clone https://github.com/rbenv/rbenv-default-gems.git ~/.rbenv/plugins/rbenv-default-gems
$ git clone https://github.com/amatsuda/gem-src.git ~/.rbenv/plugins/gem-src
```

### RubyGems

https://rubygems.org

```
$ curl -u sinsoku https://rubygems.org/api/v1/api_key.yaml > ~/.gem/credentials; chmod 0600 ~/.gem/credentials
```

## Node

https://github.com/creationix/nvm

```
$ curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.1/install.sh | bash
```

## Vim

https://github.com/junegunn/vim-plug

```
$ curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

## install

```
$ ./install.sh
```

## manual install

### from App Store

- Twitter
- 1Password

### from web

- [Docker for Mac](https://docs.docker.com/docker-for-mac/)
- [Terraform](https://www.terraform.io/)
