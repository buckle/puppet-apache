define apache::auth::digest::file::user (
  $vhost,
  $ensure='present',
  $authname='Private Area',
  $location='/',
  $authUserFile=false,
  $users='valid-user'
){

  $fname = regsubst($name, '\s\/', '_', 'G')

  include apache::params
  include concat::setup

  if ! defined(Apache::Module['authn_file']) {
    apache::module {'authn_file': }
  }
  if ! defined(Apache::Module['auth_digest']) {
    apache::module {'auth_digest': }
  }

  if $authUserFile {
    $_authUserFile = $authUserFile
  } else {
    $_authUserFile = "${apache::params::root}/${vhost}/private/.htdigest_pw"
  }
  concat { $_authUserFile:
    owner => root,
    group => root,
    mode  => '644',
  }

  if $users != 'valid-user' {
    $_users = "user $users"
  } else {
    $_users = $users
  }

  file {"${apache::params::root}/${vhost}/conf/auth-digest-file-user-${fname}.conf":
    ensure => $ensure,
    content => template('apache/auth-digest-file-user.erb'),
    seltype => $::operatingsystem ? {
      'RedHat' => 'httpd_config_t',
      'CentOS' => 'httpd_config_t',
      default  => undef,
    },
    notify => Exec['apache-graceful'],
  }

}
