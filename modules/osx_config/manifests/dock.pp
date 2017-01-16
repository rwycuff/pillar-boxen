class osx_config::dock {

  notify { 'class osx::dock declared': }

  class { 'osx::dock::icon_size': size => 18 }

}