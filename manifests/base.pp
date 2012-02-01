/*

== Class: apache::base

Common building blocks between apache::debian and apache::redhat.

It shouldn't be necessary to directly include this class.

*/
class apache::base {

  include apache::params
  include bke_firewall::http_server
  include concat::setup

  $access_log = $apache::params::access_log
  $error_log  = $apache::params::error_log

  file {"root directory":
    path => $apache::params::root,
    ensure => directory,
    mode => 755,
    owner => "root",
    group => "root",
    require => Package["apache"],
  }

  concat { "${apache::params::conf_dir}/ports.conf": }

  file {"log directory":
    path => $apache::params::log_dir,
    ensure => directory,
    mode => 700,
    owner => "root",
    group  => "root",
    require => Package["apache"],
  }

  user { "apache user":
    name    => $apache::params::http_user,
    ensure  => present,
    require => Package["apache"],
    shell   => "/sbin/nologin",
  }

  group { "apache group":
    name    => $apache::params::http_user,
    ensure  => present,
    require => Package["apache"],
  }

  package { "apache":
    name   => $apache::params::package_name,
    ensure => installed,
  }

  service { "apache":
    name       => $apache::params::package_name,
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => Package["apache"],
  }

  file {"logrotate configuration":
    path => undef,
    ensure => present,
    owner => root,
    group => root,
    mode => 644,
    source => undef,
    require => Package["apache"],
  }

  apache::listen { "80": ensure => present }
  apache::namevhost { "*:80": ensure => present }

  apache::module {["alias", "auth_basic", "authn_file", "authz_groupfile", "authz_host", "authz_user", "dir", "env", "mime", "rewrite", "setenvif", "status",]:
    ensure => present,
  }

  file {"default virtualhost":
    path    => "${apache::params::conf_dir}/sites-available/default",
    ensure  => present,
    content => template("apache/default-vhost.erb"),
    require => Package["apache"],
    notify  => Exec["apache-graceful"],
    mode    => 644,
  }

  exec { "apache-graceful":
    command => undef,
    refreshonly => true,
    onlyif => undef,
  }

  file {"/usr/local/bin/htgroup":
    ensure => present,
    owner => root,
    group => root,
    mode => 755,
    source => "puppet:///modules/${module_name}/usr/local/bin/htgroup",
  }

}
