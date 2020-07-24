node.reverse_merge!(
  nodenv: {
    plugins:  {},
    scheme:   'git',
    user:     ENV['USER'],
    versions: [],
    install_dependency: true,
    install_development_dependency: false,
  },
  :'node-build' => {
    install: true,
    build_envs: [],
  }
)

unless node[:nodenv][:nodenv_root]
  case node[:platform]
  when 'osx', 'darwin'
    user_dir = '/Users'
  else
    user_dir = '/home'
  end
  node[:nodenv][:nodenv_root] = File.join(user_dir, node[:nodenv][:user], '.nodenv')
end

include_recipe 'nodenv::install'
