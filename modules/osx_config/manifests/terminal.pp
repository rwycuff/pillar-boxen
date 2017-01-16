class osx_config::terminal {

  notify { 'class osx::terminal declared': }

  boxen::osx_defaults {
    'Only use UTF-8 in Terminal.app':
      ensure => present,
      key    => 'StringEncodings',
      domain => 'com.apple.terminal',
      value  => '4',
      type   => 'array',
      user   => $::boxen_user;
  }

}