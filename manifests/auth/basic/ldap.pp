define apache::auth::basic::ldap (
  $vhost,
  $authLDAPUrl,
  $ensure='present',
  $authname='Private Area',
  $location='/',
  $authLDAPBindDN=false,
  $authLDAPBindPassword=false,
  $authLDAPCharsetConfig=false,
  $authLDAPCompareDNOnServer=false,
  $authLDAPDereferenceAliases=false,
  $authLDAPGroupAttribute=false,
  $authLDAPGroupAttributeIsDN=false,
  $authLDAPRemoteUserAttribute=false,
  $authLDAPRemoteUserIsDN=false,
  $authzLDAPAuthoritative=false,
  $authzRequire='valid-user'
){

  $fname = regsubst($name, '\s', '_', 'G')

  include apache::params

  if defined(Apache::Module['ldap']) {} else {
    apache::module {'ldap': }
  }

  if defined(Apache::Module['authnz_ldap']) {} else {
    apache::module {'authnz_ldap': }
  }

  # Set up LDAPS
  file { "${apache::params::conf_dir}/ldaps.conf":
    ensure      => $ensure,
    content     => "#File managed by puppet
LDAPVerifyServerCert off
LDAPTrustedMode SSL",
    seltype     => $::operatingsystem ? {
      'RedHat'  => 'httpd_config_t',
      'CentOS'  => 'httpd_config_t',
      default   => undef,
    },
    notify      => Exec['apache-graceful'],
  }

  file { "${apache::params::root}/${vhost}/conf/auth-basic-ldap-${fname}.conf":
    ensure      => $ensure,
    content     => template('apache/auth-basic-ldap.erb'),
    seltype     => $::operatingsystem ? {
      'RedHat'  => 'httpd_config_t',
      'CentOS'  => 'httpd_config_t',
      default   => undef,
    },
    notify      => Exec['apache-graceful'],
  }

}
