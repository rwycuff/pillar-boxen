class osx_config {
  
  notify { 'class osx_config declared': }

  include osx_config::system
  include osx_config::global
  include osx_config::keyboard
  include osx_config::mouse
  include osx_config::terminal
  include osx_config::finder
  include osx_config::dock

}
