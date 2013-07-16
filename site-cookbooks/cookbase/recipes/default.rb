
# Install sublime text 2, ah and create a symbolic link ... in the path
dmg_package 'Sublime Text 2' do
  source "#{node[:cookbase][:st_pkg_url]}"
  checksum "906e71e19ae5321f80e7cf42eab8355146d8f2c3fd55be1f7fe5c62c57165add"
end
link "/usr/local/bin/subl" do
  to '/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl'
end

# Install latest vagrant

dmg_package 'Vagrant' do
  source "#{node[:cookbase][:vagrant_pkg_url]}"
  checksum "1581552841e076043308f330a5b1130b455c604846116c54b5330bb17240c7ee"
  type 'pkg'
  package_id 'com.vagrant.vagrant'
end

include_recipe 'cookbase::osx_hacks'