class apache::params {

  case $operatingsystem {
    'redhat', 'centos': {
      $package_name = 'httpd'
      $http_user = 'apache'
      $conf_dir = '/etc/httpd'
      $log_dir = '/var/log/httpd'
      $root = '/var/www/vhosts'
      $a2scripts_dir = '/usr/local/sbin'
    }
    'debian', 'ubuntu': {
      $package_name = apache2
      $http_user = 'www-data'
      $conf_dir = '/etc/apache2'
      $log_dir = '/var/log/apache2'
      $root = '/var/www'
      $a2scripts_dir = '/usr/sbin'
    }
  }

  $access_log = "${log}/access_log"
  $error_log = "${log}/error_log"
}
