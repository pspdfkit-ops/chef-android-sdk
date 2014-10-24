#
# Install required libraries
#
# TODO: put packages names into attributes, clean up this mess

# include_recipe 'apt'
#
# # debian specific 32bit libs via https://wiki.debian.org/Multiarch/HOWTO  (bottom)
# execute 'add i386 arch' do
#   command 'dpkg --add-architecture i386'
#   not_if 'grep i386 /var/lib/dpkg/arch'
#   notifies :run, 'execute[apt-get update]', :immediately
# end



package 'expect'

if node['platform'] == 'ubuntu'
  package 'libgl1-mesa-dev'

  #
  # Install required 32-bit libraries on 64-bit platforms
  #
  if node['kernel']['machine'] != 'i686'
    # http://askubuntu.com/questions/147400/problems-with-eclipse-and-android-sdk
    if Chef::VersionConstraint.new('>= 13.04').include?(node['platform_version'])
      package 'lib32stdc++6'
    elsif Chef::VersionConstraint.new('>= 11.10').include?(node['platform_version'])
      package 'libstdc++6:i386'
    end

    package 'lib32z1'
  end
elsif node['platform'] == 'debian' && node['kernel']['machine'] == 'i686'
  %w(
    libstdc++6:i386
    libgcc1:i386
    zlib1g:i386
    libncurses5:i386
  ).each do |pkg|
    package pkg
  end
end
