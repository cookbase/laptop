

mac_os_x_userdefaults 'Finder: show hidden files by default' do
  domain 'com.apple.finder'
  key 'AppleShowAllFiles'
  value 'true'
  type 'bool'
end

mac_os_x_userdefaults 'Finder: show all filename extensions' do
  domain 'NSGlobalDomain'
  key 'AppleShowAllExtensions'
  value 'true'
  type 'bool'
end

mac_os_x_userdefaults 'Remove the auto-hiding Dock delay' do
  domain 'com.apple.dock'
  key 'autohide-delay'
  value '0'
  type 'float'
end

mac_os_x_userdefaults 'Remove the animation when hiding/showing the Dock' do
  domain 'com.apple.dock'
  key 'autohide-time-modifier'
  value '0'
  type 'float'
end

mac_os_x_userdefaults 'Automatically hide and show the Dock' do
  domain 'com.apple.dock'
  key 'autohide'
  value 'true'
  type 'bool'
end

