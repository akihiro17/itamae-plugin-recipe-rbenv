node.reverse_merge!(
  nodenv: {
    plugins:    {},
    nodenv_root: '/usr/local/nodenv',
    scheme:     'git',
    versions:   [],
    install_dependency: true,
    install_development_dependency: false,
  },
  :'node-build' => {
    install: true,
    build_envs: [],
  }
)

include_recipe 'nodenv::install'
