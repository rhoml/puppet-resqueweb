# = Class to manage unicorn.rb file of resqueweb
define resqueweb::resource::unicorn (
  $app_name         = 'resqueweb',
  $app_path         = '/var/www/resqueweb',
  $ensure           = 'present',
  $environment      = 'default',
  $group            = 'nogroup',
  $preload          = true,
  $unicorn_timeout  = '30',
  $user             = 'deploy',
  $unicorn_port     = '8061',
  $worker_processes = '2'
) {

  File {
    owner   => 'deploy',
    group   => 'nogroup',
    mode    => '0644',
    recurse => true,
  }

## Shared Variables
  $ensure_real = $ensure ? {
    'absent' => absent,
    default  => file,
  }

  # Ensure /var/www/resqueweb/current/config diretory exists
  if ! defined(File["${app_path}/current/config"]) {
    file { "${app_path}/current/config": ensure  => 'directory' }
  }

  file { "${app_path}/current/config/unicorn.rb":
    ensure  => "${ensure_real}",
    content => template('resqueweb/unicorn.rb.erb'),
    notify  => Exec['restart-unicorn']
  }
}

