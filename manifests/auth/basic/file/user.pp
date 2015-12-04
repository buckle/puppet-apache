define apache::auth::basic::file::user (
  $vhost,
  $ensure='present',
  $authname='Private Area',
  $location='/',
  $authUserFile=false,
  $users='valid-user'
){

  $fname = regsubst($name, '\s', '_', 'G')

  include apache::params

  if ! defined(Apache::Module['authn_file']) {
    apache::module {'authn_file': }
  }

  if ($authUserFile) {
    $local_authUserFile = $authUserFile
  } else {
    $local_authUserFile = "${apache::params::root}/${vhost}/private/htpasswd"
  }

  if ($users != 'valid-user') {
    $local_users = "user ${users}"
  } else {
    $local_users = $users
  }

  file {"${apache::params::root}/${vhost}/conf/auth-basic-file-user-${fname}.conf":
    ensure      => $ensure,
    content     => template('apache/auth-basic-file-user.erb'),
    seltype     => $::operatingsystem ? {
      'RedHat'  => 'httpd_config_t',
      'CentOS'  => 'httpd_config_t',
      default   => undef,
    },
    notify      => Exec['apache-graceful'],
  }

}
