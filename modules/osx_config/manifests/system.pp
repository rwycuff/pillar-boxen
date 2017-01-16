class osx_config::system {

  notify { 'class osx::system declared': }

  exec { 'Turn on screen sharing':
    command => 'sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -privs -all -restart -agent -menu' 
  }
  exec { 'Turn on remote login':
    command => 'sudo systemsetup -setremotelogin on' 
  }
  exec { 'Set display sleep':
    command => 'sudo systemsetup -setdisplaysleep 10' 
  }
  exec { 'Set computer sleep':
    command => 'sudo systemsetup -setcomputersleep Never' 
  }
  exec { 'Set hard disk sleep':
    command => 'sudo systemsetup -setharddisksleep Never' 
  }

}