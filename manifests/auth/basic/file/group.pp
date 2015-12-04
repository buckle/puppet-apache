define apache::auth::basic::file::group (
  $vhost,
  $groups,
  $ensure='present',
  $authname='Private Area',
  $location='/',
  $authUserFile=false,
  $authGroupFile=false
){

  $fname = regsubst($name, '\s', '_', 'G')

  include apache::params

  if defined(Apache::Module['authn_file']) {} else {
    apache::module {'authn_file': }
  }

  if ($authUserFile) {
    $local_authUserFile = $authUserFile
  } else {
    $local_authUserFile = "${apache::params::root}/${vhost}/private/htpasswd"
  }

  if ($authGroupFile) {
    $local_authGroupFile = $authGroupFile
  } else {
    $local_authGroupFile = "${apache::params::root}/${vhost}/private/htgroup"
  }

  file { "${apache::params::root}/${vhost}/conf/auth-basic-file-group-${fname}.conf":
    ensure     => $ensure,
    content    => template('apache/auth-basic-file-group.erb'),
    seltype    => $::operatingsystem ? {
      'RedHat' => 'httpd_config_t',
      'CentOS' => 'httpd_config_t',
      default  => undef,
    },
    notify     => Exec['apache-graceful'],
  }

}
