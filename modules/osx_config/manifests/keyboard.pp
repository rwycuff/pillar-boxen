class osx_config::keyboard {

  notify { 'class osx::keyboard declared': }

  include osx::universal_access::ctrl_mod_zoom
  include osx::global::enable_keyboard_control_access
  include osx::global::enable_standard_function_keys

  class { 'osx::global::key_repeat_delay': delay => 30 }
  class { 'osx::global::key_repeat_rate': rate => 2 }

}