class apache::administration {

  include apache::params

  $distro_specific_apache_sudo = $::operatingsystem ? {
    /RedHat|CentOS/ => "/usr/sbin/apachectl, /sbin/service ${apache::params::package_name}",
    /Debian|Ubuntu/ => '/usr/sbin/apache2ctl',
    default         => undef
  }

  group { 'apache-admin':
    ensure => present,
  }

  # used in erb template
  $wwwpkgname = $apache::params::package_name
  $wwwuser    = $apache::params::http_user

  sudo::directive { 'apache-administration':
    ensure => present,
    content => template('apache/sudoers.apache.erb'),
    require => Group['apache-admin'],
  }

}
