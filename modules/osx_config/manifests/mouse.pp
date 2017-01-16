class osx_config::mouse {

  notify { 'class osx::mouse declared': }

  include osx::global::expand_print_dialog
  include osx::global::expand_save_dialog
  include osx::global::disable_autocorrect

  include osx::disable_app_quarantine
  include osx::no_network_dsstores
  include osx::safari::enable_developer_mode

}