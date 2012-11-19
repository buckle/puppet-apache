define apache::auth::basic::file::webdav::user (
  $vhost,
  $ensure='present',
  $authname='Private Area',
  $location='/',
  $authUserFile=false,
  $rw_users='valid-user',
  $limits='GET HEAD OPTIONS PROPFIND',
  $ro_users=False,
  $allow_anonymous=false,
  $users='valid-user'
) {

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

  if ($users != 'valid-user') {
    $local_users = "user ${rw_users}"
  } else {
    $local_users = $users
  }

  file { "${apache::params::root}/${vhost}/conf/auth-basic-file-webdav-${fname}.conf":
    ensure      => $ensure,
    content     => template('apache/auth-basic-file-webdav-user.erb'),
    seltype     => $::operatingsystem ? {
      'RedHat'  => 'httpd_config_t',
      'CentOS'  => 'httpd_config_t',
      default   => undef,
    },
    notify      => Exec['apache-graceful'],
  }

}
