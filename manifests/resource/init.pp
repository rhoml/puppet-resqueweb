# = Class to manage unicorn.rb file of resqueweb
define resqueweb::resource::init (
  $app_name         = 'resqueweb',
  $ensure           = 'present',
  $prefix           = '/etc/init.d',
  $user             = 'deploy'
) {

  File {
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

## Shared Variables
  $ensure_real = $ensure ? {
    'absent' => absent,
    default  => file,
  }

  file { "${prefix}/${name}":
    ensure  => "${ensure_real}",
    content => template('resqueweb/unicorn-init.erb'),
    notify  => Exec['restart-unicorn']
  }

  file { '/etc/rc2.d/S02unicorn-queues':
    ensure => 'link',
    target => "${prefix}/unicorn-queues"
  }
}
