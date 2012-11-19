define apache::userdirinstance (
  $vhost,
  $ensure=present
) {

  include apache::params

  file { "${apache::params::root}/${vhost}/conf/userdir.conf":
    ensure    => $ensure,
    source    => "puppet:///modules/${module_name}/userdir.conf",
    seltype   => $::operatingsystem ? {
      'RedHat'=> 'httpd_config_t',
      'CentOS'=> 'httpd_config_t',
      default => undef,
    },
    notify    => Exec['apache-graceful'],
  }
}
