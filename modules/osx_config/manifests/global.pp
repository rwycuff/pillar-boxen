class osx_config::global {

  notify { 'class osx::global declared': }

  include osx::universal_access::enable_scrollwheel_zoom

  class { 'osx::mouse::button_mode': mode => 2 }  # right click

}