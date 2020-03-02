# This recipe requires `rbenv_root` is defined.

if node[:rbenv][:install_development_dependency]
  include_recipe 'rbenv::development_dependency'
end
if node[:rbenv][:install_dependency]
  include_recipe 'rbenv::dependency'
end

scheme     = node[:rbenv][:scheme]
rbenv_root = node[:rbenv][:rbenv_root]

git rbenv_root do
  repository "#{scheme}://github.com/rbenv/rbenv.git"
  revision node[:rbenv][:revision] if node[:rbenv][:revision]
  user node[:rbenv][:user] if node[:rbenv][:user]
end

directory File.join(rbenv_root, 'plugins') do
  user node[:rbenv][:user] if node[:rbenv][:user]
end
if node[:rbenv][:cache]
  directory File.join(rbenv_root, 'cache') do
    user node[:rbenv][:user] if node[:rbenv][:user]
  end
end

define :rbenv_plugin, group: 'rbenv', revision: nil, install: nil do
  name = params[:name]
  group = params[:group]
  rev = params[:revision]
  if params[:install] == false
    install = false
  else
    install = true
  end

  if install || rev
    git "#{rbenv_root}/plugins/#{name}" do
      repository "#{scheme}://github.com/#{group}/#{name}.git"
      revision rev if rev
      user node[:rbenv][:user] if node[:rbenv][:user]
    end
  end
end

if node[:'rbenv-default-gems'] && node[:'rbenv-default-gems'][:'default-gems']
  rbenv_plugin 'rbenv-default-gems' do
    revision node[:'rbenv-default-gems'][:revision]
    install node[:'rbenv-default-gems'][:install]
  end

  node[:'rbenv-default-gems'][:install] = true
  file "#{rbenv_root}/default-gems" do
    content node[:'rbenv-default-gems'][:'default-gems'].join("\n") + "\n"
    mode    '664'
    if node[:rbenv][:user]
      owner node[:rbenv][:user]
      group node[:rbenv][:group] || node[:rbenv][:user]
    end
  end
end

rbenv_plugin 'ruby-build' do
  revision node[:'ruby-build'][:revision]
  install node[:'ruby-build'][:install]
end

rbenv_init = <<-EOS
  export RBENV_ROOT=#{rbenv_root}
  export PATH="#{rbenv_root}/bin:${PATH}"
  eval "$(rbenv init --no-rehash -)"
EOS

build_envs = node[:'ruby-build'][:build_envs].map do |key, value|
  %Q[export #{key}="#{value}"\n]
end.join

node[:rbenv][:versions].each do |version|
  execute "rbenv install #{version}" do
    command "#{rbenv_init} #{build_envs} rbenv install #{version}"
    not_if  "#{rbenv_init} rbenv versions --bare | grep -x #{version}"
    user node[:rbenv][:user] if node[:rbenv][:user]
  end
end

if node[:rbenv][:global]
  node[:rbenv][:global].tap do |version|
    execute "rbenv global #{version}" do
      command "#{rbenv_init} rbenv global #{version}"
      not_if  "#{rbenv_init} rbenv global | grep -x #{version}"
      user node[:rbenv][:user] if node[:rbenv][:user]
    end
  end
end

node[:rbenv][:plugins].each do |name, options|
  if name.include?('/')
    owner, repo = name.split('/', 2)
  else
    owner, repo = 'rbenv', name
  end

  rbenv_plugin repo do
    group owner
    revision options[:revision]
  end
end
