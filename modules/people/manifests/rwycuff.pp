class people::rwycuff {

  notify { 'class people::rwycuff declared': }

  include people::rwycuff::config::osx
  include people::rwycuff::config::gitconfig

}
