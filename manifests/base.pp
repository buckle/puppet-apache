/*
 *
 * == Class: apache::base
 *
 * Common building blocks between apache::debian and apache::redhat.
 *
 * It shouldn't be necessary to directly include this class.
 */
class apache::base {
  include apache::params
  include bke_firewall::http_server
  include concat::setup

  $access_log = $apache::params::access_log
  $error_log = $apache::params::error_log

  file { 'root directory':
    ensure  => 'directory',
    path    => $apache::params::root,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    require => Package['apache'],
  }

  concat { "${apache::params::conf_dir}/ports.conf":
  }

  file { 'log directory':
    ensure  => 'directory',
    path    => $apache::params::log_dir,
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    require => Package['apache'],
  }

  user { 'apache user':
    ensure  => 'present',
    name    => $apache::params::http_user,
    require => Package['apache'],
    shell   => '/sbin/nologin',
  }

  group { 'apache group':
    ensure  => 'present',
    name    => $apache::params::http_user,
    require => Package['apache'],
  }

  package { 'apache':
    ensure => 'present',
    name   => $apache::params::package_name,
  }

  file { 'Apache init script':
    ensure  => 'present',
    path    => '/etc/init.d/apache',
    mode    => '0755',
  }

  service { 'apache':
    ensure     => 'running',
    name       => $apache::params::package_name,
    enable     => true,
    hasrestart => true,
    require    => [Package['apache'],File['Apache init script']],
  }

  file { 'logrotate configuration':
    ensure  => 'present',
    path    => undef,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => undef,
    require => Package['apache'],
  }

  apache::listen { '80':
    ensure  => 'present',
  }

  apache::namevhost { '*:80':
    ensure  => 'present',
  }

  apache::module { [
    'alias',
    'auth_basic',
    'authn_file',
    'authz_groupfile',
    'authz_host',
    'authz_user',
    'dir',
    'env',
    'mime',
    'rewrite',
    'setenvif',
    'status',]:
    ensure => present,
  }

  file { 'default status module configuration':
    ensure  => 'present',
    path    => undef,
    owner   => 'root',
    group   => 'root',
    source  => undef,
    require => Module['status'],
    notify  => Exec['apache-graceful'],
  }

  file { 'default virtualhost':
    ensure  => 'present',
    path    => "${apache::params::conf_dir}/sites-available/default",
    content => template('apache/default-vhost.erb'),
    require => Package['apache'],
    notify  => Exec['apache-graceful'],
    mode    => '0644',
  }

  exec { 'apache-graceful':
    command     => undef,
    refreshonly => true,
    onlyif      => undef,
  }

  file { '/usr/local/bin/htgroup':
    ensure => 'present',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => "puppet:///modules/${module_name}/usr/local/bin/htgroup",
  }

  # rkhunter PORT_WHITELIST - requires pci module with rkhunter class
  if tagged('pci::rkhunter') {
    pci::rkhunter_conf_local { 'PORT_WHITELIST service httpd':
      key   => 'PORT_WHITELIST',
      value => '/usr/sbin/httpd',
      order => 25
    }
  }
}
