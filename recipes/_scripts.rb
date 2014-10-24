#
# Deploy additional scripts, preferably outside Android-SDK own directories to
# avoid unwanted removal when updating android sdk components later.
#
%w(android-accept-licenses android-wait-for-emulator).each do |android_helper_script|
  cookbook_file File.join(node['android-sdk']['scripts']['path'], android_helper_script) do
    source android_helper_script
    owner node['android-sdk']['scripts']['owner']
    group node['android-sdk']['scripts']['group']
    mode 0755
  end
end
%w(android-update-sdk).each do |android_helper_script|
  template File.join(node['android-sdk']['scripts']['path'], android_helper_script) do
    source "#{android_helper_script}.erb"
    owner node['android-sdk']['scripts']['owner']
    group node['android-sdk']['scripts']['group']
    mode 0755
  end
end
