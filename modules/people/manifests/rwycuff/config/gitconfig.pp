class people::ddaugher::config::gitconfig {
  
  # remove the base git config in order to properly install new
  file { "/Users/admin/.gitconfig":
    content => '',
  }

  git::config::global {
    'user.name':    value => 'Ryan Wycuff', require => File['/Users/admin/.gitconfig'];
    'user.email':   value => 'rwycuff@pillartechnology.com';
    'color.ui':     value => 'auto';
    'github.user':  value => 'rwycuff';
    'push.default': value => 'simple';
    'alias.a':      value => 'add';
    'alias.aa':     value => 'add -A';
    'alias.bv':     value => 'branch -avv';
    'alias.co':     value => 'checkout';
    'alias.c':      value => 'commit';
    'alias.cm':     value => 'commit -m';
    'alias.ca':     value => 'commit -a';
    'alias.cam':    value => 'commit -a -m';
    'alias.d':      value => 'diff';
    'alias.ds':     value => 'diff --stat';
    'alias.l':      value => 'log --graph --pretty=format:\'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset\' --abbrev-commit --date=relative';
    'alias.l1':     value => 'log --pretty=oneline';
    'alias.s':      value => 'status';
  }
}
