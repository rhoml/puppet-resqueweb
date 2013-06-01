# = Class to manage config.ru file of resqueweb
define resqueweb::resource::config (
  $app_path         = '/var/www/resqueweb',
  $apps             = 'app1 app2',
  $countries        = 'es uk',
  $ensure           = 'present',
  $stages           = 'dev staging',
  $redis_host       = 'redis.domain.com',
  $redis_port       = '6371'
) {

  File {
    owner   => 'deploy',
    group   => 'nogroup',
    mode    => '0644',
  }

## Shared Variables
  $ensure_real = $ensure ? {
    'absent' => absent,
    default  => file,
  }

  file { "${app_path}/current/${name}":
    ensure  => "${ensure_real}",
    content => template( 'resqueweb/config.ru.erb' ),
    notify  => Exec['restart-unicorn']
  }
}
