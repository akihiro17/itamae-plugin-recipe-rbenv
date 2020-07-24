# This recipe requires `nodenv_root` is defined.

if node[:nodenv][:install_development_dependency]
  include_recipe 'nodenv::development_dependency'
end
if node[:nodenv][:install_dependency]
  include_recipe 'nodenv::dependency'
end

scheme     = node[:nodenv][:scheme]
nodenv_root = node[:nodenv][:nodenv_root]

git nodenv_root do
  repository "#{scheme}://github.com/nodenv/nodenv.git"
  revision node[:nodenv][:revision] if node[:nodenv][:revision]
  user node[:nodenv][:user] if node[:nodenv][:user]
end

directory File.join(nodenv_root, 'plugins') do
  user node[:nodenv][:user] if node[:nodenv][:user]
end
if node[:nodenv][:cache]
  directory File.join(nodenv_root, 'cache') do
    user node[:nodenv][:user] if node[:nodenv][:user]
  end
end

define :nodenv_plugin, group: 'nodenv', revision: nil, install: nil do
  name = params[:name]
  group = params[:group]
  rev = params[:revision]
  if params[:install] == false
    install = false
  else
    install = true
  end

  if install || rev
    git "#{nodenv_root}/plugins/#{name}" do
      repository "#{scheme}://github.com/#{group}/#{name}.git"
      revision rev if rev
      user node[:nodenv][:user] if node[:nodenv][:user]
    end
  end
end

nodenv_plugin 'node-build' do
  revision node[:'node-build'][:revision]
  install node[:'node-build'][:install]
end

nodenv_init = <<-EOS
  export RBENV_ROOT=#{nodenv_root}
  export PATH="#{nodenv_root}/bin:${PATH}"
  eval "$(nodenv init --no-rehash -)"
EOS

build_envs = node[:'node-build'][:build_envs].map do |key, value|
  %Q[export #{key}="#{value}"\n]
end.join

node[:nodenv][:versions].each do |version|
  execute "nodenv install #{version}" do
    command "#{nodenv_init} #{build_envs} nodenv install #{version}"
    not_if  "#{nodenv_init} nodenv versions --bare | grep -x #{version}"
    user node[:nodenv][:user] if node[:nodenv][:user]
  end
end

if node[:nodenv][:global]
  node[:nodenv][:global].tap do |version|
    execute "nodenv global #{version}" do
      command "#{nodenv_init} nodenv global #{version}"
      not_if  "#{nodenv_init} nodenv global | grep -x #{version}"
      user node[:nodenv][:user] if node[:nodenv][:user]
    end
  end
end

node[:nodenv][:plugins].each do |name, options|
  if name.include?('/')
    owner, repo = name.split('/', 2)
  else
    owner, repo = 'nodenv', name
  end

  nodenv_plugin repo do
    group owner
    revision options[:revision]
  end
end
