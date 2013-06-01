# = Class to install resque Web.
class resqueweb::install (
  $prefix     = '/var/www',
  $user       = 'deploy',
  $version    = '1.24.1'
) {

  require rbenv

    File {
    owner   => 'deploy',
    group   => 'nogroup',
    mode    => '0644',
  }

  # Ensure /var/run/unicorn diretory exists
  if ! defined(File['/var/run/unicorn']) {
    file { '/var/run/unicorn':
      ensure  => 'directory',
    }
  }

  # Ensure /var/run/unicorn diretory exists
  if ! defined(File['/var/run/queue']) {
    file { '/var/run/queue':
      ensure  => 'directory',
    }
  }


  # Ensure /var/run/unicorn/pids diretory exists
  if ! defined(File['/var/run/unicorn/pids']) {
    file { '/var/run/unicorn/pids':
      ensure  => 'directory',
    }
  }

  # Ensure /var/www diretory exists
  if ! defined(File["${prefix}"]) {
    file { "${prefix}":
      ensure  => 'directory',
    }
  }

  # Ensure /var/www/resqueweb diretory exists
  if ! defined(File["${prefix}/resqueweb"]) {
    file { "${prefix}/resqueweb":
      ensure  => 'directory',
      recurse => true,
      require => File["${prefix}"]
    }
  }

  # Ensure /var/www/resqueweb/shared diretory exists
  if ! defined(File["${prefix}/resqueweb/shared"]) {
    file { "${prefix}/resqueweb/shared":
      ensure  => 'directory',
      require => File["${prefix}/resqueweb"]
    }
  }

  # Ensure /var/www/resqueweb/shared/log diretory exists
  if ! defined(File["${prefix}/resqueweb/shared/log"]) {
    file { "${prefix}/resqueweb/shared/log":
      ensure  => 'directory',
      recurse => true,
      require => File["${prefix}/resqueweb/shared"]
    }
  }

  # Download the resqeweb tar compressed file
  file { "${prefix}/resqueweb/resqueweb-${version}.tar.gz":
    source  => "puppet:///modules/resqueweb/resqueweb-${version}.tar.gz",
    alias   => 'resqueweb-source-tgz',
    before  => Exec['untar-resqueweb-source']
  }

  # Untar resqueweb file
  exec { "tar xzf resqueweb-${version}.tar.gz":
    path       => [ "/bin/", "/sbin/", "/usr/bin/" ],
    cwd        => "${prefix}/resqueweb",
    creates    => "${prefix}/resqueweb/current",
    alias      => "untar-resqueweb-source",
    subscribe  => File["resqueweb-source-tgz"]
  }

  # bundle resqueweb
  exec { "/bin/ls | su - ${user}; bundle install":
    path    => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/home/${user}/.rbenv/shims" ],
    cwd     => "${prefix}/resqueweb/current",
    require => Exec['untar-resqueweb-source'],
    creates => "${prefix}/resqueweb/current/Gemfile.lock",
    alias   => "bundle-resqueweb"
    }

  # Ensure /var/www/resqueweb/current/log diretory exists
  if ! defined(File["${prefix}/resqueweb/current/log"]) {
    file { "${prefix}/resqueweb/current/log":
      ensure  => 'link',
      target  => "${prefix}/resqueweb/shared/log",
      require => Exec["untar-resqueweb-source"]
    }
  }

}
