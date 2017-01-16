require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::homebrewdir}/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  include nginx
  include brewcask

  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # node versions
  nodejs::version { '0.12.2': }
  nodejs::module { 'npm': node_version => 'v0.12.2' }

  # default ruby versions
  ruby::version { '2.2.4': }
  class { 'ruby::global': version => '2.2.4' }
  ruby_gem { 'bundler':
    gem          => 'bundler',
    ruby_version => '*',
  }
    ruby_gem { 'cocoapods': 
    gem          => 'cocoapods',
    ruby_version => '*',
  }
  ruby_gem { 'ocunit2junit': # not sure if this is necessary here
    gem          => 'ocunit2junit',
    ruby_version => '*',
  }

  # common, useful packages -- brew
  package { 
    [
      'docker',            #  
      'git',               #
      'openssl',           #
      'p7zip',             # 7z, XZ, BZIP2, GZIP, TAR, ZIP and WIM
      'rbenv',             # ruby environment manager
      'wget',              #
      'xctool',            # xcode build, used by sonar
    ]: 
    ensure => present
  }

  # packages that should not be present anymore
  package { 'android-sdk': ensure => absent }   # instead, custom pre-populated android-sdk installed after boxen

  # common, useful packages -- brew-cask
  package { [
      'android-studio',
      'genymotion',        # android in virtualbox (faster) 
      'google-chrome',     # browser
      'jetbrains-toolbox', # IDE all the things
      'java',              # java 8
      'qlgradle',          # quicklook for gradle files
      'qlmarkdown',        # quicklook for md files
      'qlprettypatch',     # quicklook for patch files
      'qlstephen',         # quicklook for text files
      'slack',             # communication tool
      'virtualbox',        # 
      'mailbox',           # email client
    ]: 
    provider => 'brewcask', 
    ensure => present
  }

  exec { 'sudo /usr/sbin/DevToolsSecurity --enable': }

  # geofencing uses python scripts
  exec { 'pip':  # python package manager  
    command => 'sudo easy_install pip'
  }

  exec { 'virtualenv':  # python environment manager
    command => 'sudo pip install virtualenv',
    require => Exec['pip']
  }

  
  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }
}
