class apache::redhat(
  $start_servers,
  $min_spare_servers,
  $max_spare_servers,
  $server_limit,
  $max_clients,
  $max_requests_per_child,
  $listen_backlog,
  $request_timeout,
  $keepalive,
  $max_keepalive_requests,
  $keepalive_timeout,
  $threads_per_child,
  $apache_mpm_type = ''
) inherits apache::base {

  include apache::params

  # BEGIN inheritance from apache::base
  Exec['apache-graceful'] {
    command => '/usr/sbin/apachectl graceful',
    onlyif  => '/usr/sbin/apachectl configtest',
  }

  Package['apache'] {
    require => [
      File["${apache::params::a2scripts_dir}/a2ensite"],
      File["${apache::params::a2scripts_dir}/a2dissite"],
      File["${apache::params::a2scripts_dir}/a2enmod"],
      File["${apache::params::a2scripts_dir}/a2dismod"]
    ],
  }

  File['Apache init script'] {
    path    => '/etc/init.d/httpd',
    source  => "puppet:///modules/${module_name}/httpd.init",
  }

  File['default status module configuration'] {
    path    => "${apache::params::conf_dir}/conf.d/status.conf",
    source  => 'puppet:///modules/apache/etc/httpd/conf/status.conf',
  }

  File['logrotate configuration'] {
    path    => '/etc/logrotate.d/httpd',
    content => template('apache/logrotate-httpd.erb'),
  }

  File['default virtualhost'] {
    seltype => 'httpd_config_t',
  }
  # END inheritance from apache::base

  file { [
      "${apache::params::a2scripts_dir}/a2ensite",
      "${apache::params::a2scripts_dir}/a2dissite",
      "${apache::params::a2scripts_dir}/a2enmod",
      "${apache::params::a2scripts_dir}/a2dismod"
    ]:
    ensure  => present,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    source  => "puppet:///modules/${module_name}/usr/local/sbin/a2X.redhat",
  }

  $httpd_mpm = $apache_mpm_type ? {
    ''         => 'httpd', # default MPM
    'pre-fork' => 'httpd',
    'prefork'  => 'httpd',
    default    => "httpd.${apache_mpm_type}",
  }

  Augeas {
    notify  => Service['apache'],
    require => Package['apache'],
  }

#  augeas { "select httpd mpm ${httpd_mpm}":
#    lens    => 'Sysconfig.lns',
#    incl    => '/etc/sysconfig/httpd',
#    context => '/files/etc/sysconfig/httpd',
#    changes => [ "set HTTPD /usr/sbin/${httpd_mpm}", ],
#    onlyif  => "get HTTPD != /usr/sbin/${httpd_mpm}",
#  }

  augeas { "select httpd mpm ${httpd_mpm}":
    changes => "set /files/etc/sysconfig/httpd/HTTPD /usr/sbin/${httpd_mpm}",
    require => Package['apache'],
    notify  => Service['apache'],
  }

  # Disable the welcome page, we make sure it's empty to prevent it from being reinstalled with RPM upgrades
  file { "${apache::params::conf_dir}/conf.d/welcome.conf":
    ensure  => present,
    content => "\n",
    require => Package['apache'],
    notify  => Exec['apache-graceful'],
  }

  file { [
      "${apache::params::conf_dir}/sites-available",
      "${apache::params::conf_dir}/sites-enabled",
      "${apache::params::conf_dir}/mods-enabled"
    ]:
    ensure  => directory,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    seltype => 'httpd_config_t',
    require => Package['apache'],
  }

  file { "${apache::params::conf_dir}/conf/httpd.conf":
    ensure  => present,
    content => template('apache/httpd.conf.erb'),
    seltype => 'httpd_config_t',
    notify  => Service['apache'],
    require => Package['apache'],
  }

  # the following command was used to generate the content of the directory:
  # egrep '(^|#)LoadModule' /etc/httpd/conf/httpd.conf | sed -r 's|#?(.+ (.+)_module .+)|echo "\1" > mods-available/redhat5/\2.load|' | sh
  # ssl.load was then changed to a template (see apache-ssl-redhat.pp)
  file { "${apache::params::conf_dir}/mods-available":
    ensure  => directory,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    seltype => 'httpd_config_t',
    require => Package['apache'],
  }

  # this module is statically compiled on debian and must be enabled here
  apache::module {['log_config']:
    ensure => present,
  }

  # it makes no sens to put CGI here, deleted from the default vhost config
  file {'/var/www/cgi-bin':
    ensure  => absent,
    force   => true,
    require => Package['apache'],
  }

  # no idea why redhat choose to put this file there. apache fails if it's
  # present and mod_proxy isn't...
  # we make sure it's empty to prevent it from being reinstalled with RPM upgrades
  file { "${apache::params::conf_dir}/conf.d/proxy_ajp.conf":
    ensure  => present,
    require => Package['apache'],
    content => "\n",
    notify  => Exec['apache-graceful'],
  }
}

