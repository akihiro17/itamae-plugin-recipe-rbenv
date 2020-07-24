# Itamae::Plugin::Recipe::Rbenv [![Build Status](https://travis-ci.org/k0kubun/itamae-plugin-recipe-nodenv.svg?branch=master)](https://travis-ci.org/akihiro17/itamae-plugin-recipe-nodenv)

[Itamae](https://github.com/ryotarai/itamae) plugin to install node with nodenv

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'itamae-plugin-recipe-nodenv'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install itamae-plugin-recipe-nodenv

# Usage
## System wide installation

Install nodenv to /usr/local/nodenv or some shared path

### Recipe

```ruby
# your recipe
include_recipe "nodenv::system"
```

### Node

Use this with `itamae -y node.yml`

```yaml
# node.yml
nodenv:
  global:
    2.3.0
  versions:
    - 2.3.0
    - 2.2.4

  # nodenv install dir, optional (default: /usr/local/nodenv)
  nodenv_root: "/path/to/nodenv"

  # specify scheme to use in git clone, optional (default: git)
  scheme: https

  # Create /usr/local/nodenv/cache, optional (default: false)
  # See: https://github.com/nodenv/node-build#package-download-caching
  cache: true

  # Whether install dependencies (default: true)
  # Recommend false if `--no-sudo`
  install_dependency: true

  # Install arbitrary nodenv plugins, optional (default: [])
  plugins:
    dcarley/nodenv-sudo:
      revision: master

# node-build is always installed. Specifying revision improves performance.
node-build:
  revision: e455975286e44393b1b33037ae1ce40ef2742401

# Optional plugin. Specify :install or :revision to install nodenv-default-gems.
nodenv-default-gems:
  default-gems:
    - bundler
    - bcat ~>0.6
    - rails --pre
  install: true
  # or
  revision: ead67889c91c53ad967f85f5a89d986fdb98f6fb
```

### .bashrc

Recommend to append this to .bashrc in your server.

```bash
export RBENV_ROOT=/usr/local/nodenv
export PATH="${RBENV_ROOT}/bin:${PATH}"
eval "$(nodenv init -)"
```

## Installation for a user

Install nodenv to `~#{node[:nodenv][:user]}/.nodenv`

### Recipe

```ruby
# your recipe
include_recipe "nodenv::user"
```

### Node

Use this with `itamae -y node.yml`

```yaml
# node.yml
nodenv:
  user: k0kubun
  global:
    2.3.0
  versions:
    - 2.3.0
    - 2.2.4

  # specify scheme to use in git clone, optional (default: git)
  scheme: https

  # Create ~/.nodenv/cache, optional (default: false)
  # See: https://github.com/nodenv/node-build#package-download-caching
  cache: true

  # Install build dependencies or not (default: true)
  # Recommend false if `--no-sudo`
  install_dependency: true

  # Install dependencies to build *-dev or not (default: false)
  install_development_dependency: false

# node-build is always installed. Specifying revision improves performance.
node-build:
  revision: e455975286e44393b1b33037ae1ce40ef2742401

# Optional plugin. Specify :install or :revision to install nodenv-default-gems.
nodenv-default-gems:
  default-gems:
    - bundler
    - bcat ~>0.6
    - rails --pre
  install: true
  # or
  revision: ead67889c91c53ad967f85f5a89d986fdb98f6fb
```

## MItamae

This plugin can be used for MItamae too. Put this repository under `./plugins` as git submodule.

```rb
node.reverse_merge!(
  nodenv: {
    user: 'k0kubun',
    global: '2.3.1',
    versions: %w[
      2.3.1
      2.2.5
    ],
  }
)

include_recipe "nodenv::user"
```

## License

MIT License
