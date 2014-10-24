# TODO: move into an LWRP
setup_root       = node['android-sdk']['setup_root'].to_s.empty? ? node['ark']['prefix_home'] : node['android-sdk']['setup_root']
android_home     = File.join(setup_root, node['android-sdk']['name'])
android_bin      = File.join(android_home, 'tools', 'android')

# With "--filter node['android-sdk']['components'].join(,)" pattern,
# some system-images were not installed as expected.
# The easiest way I could find to fix this problem consists
# in executing a dedicated 'android sdk update' command for each component to be installed.
node['android-sdk']['components'].each do |sdk_component|
  script "Install Android SDK platforms and tools #{sdk_component}" do
    interpreter 'expect'
    environment(
      'ANDROID_HOME' => android_home
    )
    path [File.join(android_home, 'tools')]
    user node['android-sdk']['owner']
    group node['android-sdk']['group']
    # TODO: use --force or not?
    code <<-EOF
      spawn #{android_bin} update sdk --no-ui --all --filter #{sdk_component}
      set timeout 1800
      expect {
        -regexp "Do you accept the license '(#{node['android-sdk']['license']['white_list'].join('|')})'.*" {
              exp_send "y\r"
              exp_continue
        }
        -regexp "Do you accept the license '(#{node['android-sdk']['license']['black_list'].join('|')})'.*" {
              exp_send "n\r"
              exp_continue
        }
        "Do you accept the license '*-license-*'*" {
              exp_send "#{node['android-sdk']['license']['default_answer']}\r"
              exp_continue
        }
        eof
      }
    EOF
    not_if { File.exist?("#{setup_root}/#{node['android-sdk']['name']}-#{node['android-sdk']['version']}/temp") }
  end
end
