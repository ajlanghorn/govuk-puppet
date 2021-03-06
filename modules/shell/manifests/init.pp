# == Class: shell
#
# Set up a shell on a machine.
#
# === Parameters
#
# [*shell_prompt_string*]
#   The environment name that should appear in the shell prompt
#
class shell (
  $shell_prompt_string = 'unknown'
){

  file { '/etc/bash.bashrc':
    content => template('shell/bashrc.erb'),
  }

  # Remove default user .bashrc
  #
  # The above system-wide bashrc will work just fine even if users don't have
  # their own .bashrc
  file { '/etc/skel/.bashrc':
    ensure => 'absent',
  }

}
