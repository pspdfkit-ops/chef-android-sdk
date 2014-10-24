setup_root       = node['android-sdk']['setup_root'].to_s.empty? ? node['ark']['prefix_home'] : node['android-sdk']['setup_root']
android_home     = File.join(setup_root, node['android-sdk']['name'])
android_bin      = File.join(android_home, 'tools', 'android')

#
# Download and setup android-sdk tarball package
#
ark node['android-sdk']['name'] do
  url node['android-sdk']['download_url']
  checksum node['android-sdk']['checksum']
  version node['android-sdk']['version']
  prefix_root node['android-sdk']['setup_root']
  prefix_home node['android-sdk']['setup_root']
  owner node['android-sdk']['owner']
  group node['android-sdk']['group']
end

#
# Fix non-friendly 0750 permissions in order to make android-sdk available to all system users
#
%w(add-ons platforms tools).each do |subfolder|
  directory File.join(android_home, subfolder) do
    mode 0755
  end
end

# TODO find a way to handle 'chmod stuff' below with own chef resource (idempotence stuff...)
execute 'Grant all users to read android files' do
  command "chmod -R a+r #{android_home}/*"
  user node['android-sdk']['owner']
  group node['android-sdk']['group']
end

execute 'Grant all users to execute android tools' do
  command "chmod -R a+X #{File.join(android_home, 'tools')}/*"
  user node['android-sdk']['owner']
  group node['android-sdk']['group']
end

#
# Configure environment variables (ANDROID_HOME and PATH)
#
template "/etc/profile.d/#{node['android-sdk']['name']}.sh"  do
  source 'android-sdk.sh.erb'
  mode 0644
  owner node['android-sdk']['owner']
  group node['android-sdk']['group']
  variables(
    android_home: android_home
  )
end
