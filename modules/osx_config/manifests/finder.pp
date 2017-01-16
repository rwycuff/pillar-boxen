class osx_config::finder {

  notify { 'class osx::finder declared': }

  include osx::finder::unhide_library
  include osx::finder::show_hidden_files
  include osx::finder::enable_quicklook_text_selection
  include osx::finder::show_all_filename_extensions

  boxen::osx_defaults { 'Show Path Bar in Finder': 
    user   => $::boxen_user,
    domain => 'com.apple.finder',
    key    => 'ShowPathbar',  #lowercase 'b' is correct here
    value  => true,
    notify => Exec['killall Finder']
  }
  boxen::osx_defaults { 'Show Status Bar in Finder': 
    user   => $::boxen_user,
    domain => 'com.apple.finder',
    key    => 'ShowStatusBar', 
    value  => true,
    notify => Exec['killall Finder']
  }
  boxen::osx_defaults { 'Show Tab Bar in Finder': 
    user   => $::boxen_user,
    domain => 'com.apple.finder',
    key    => 'ShowTabView', 
    value  => true,
    notify => Exec['killall Finder']
  }

}