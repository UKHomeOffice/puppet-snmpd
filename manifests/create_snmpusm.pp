#
# Defines a snmpd user
#
define snmpd::create_snmpusm (
  $authtype = 'SHA',
  $privtype = 'AES',
  $authpass = '',
  $privpass = '',
  $secmode  = 'noauth',
  $acl      = 'rouser'
) {
  include snmpd
  include snmpd::params

  validate_re($secmode,'^noauth$|^auth$|^priv$')
  validate_re($acl,'^rouser$|^rwuser$')

  if $privpass {
    $createcmd = "createUser ${title} ${authtype} ${authpass} ${privtype} ${privpass}"
  } else {
    $createcmd = "createUser ${title} ${authtype} ${authpass}"
  }

  $check_usm_user_exists = "/bin/awk \'/^usmUser/ {print \$5}\' ${snmpd::params::var_net_snmpd}/snmpd.conf | xxd -r -p | grep ${title} > /dev/null 2>&1"

  datacat_fragment {"${title} - create snmpv3 usm user":
    target => "${icinga::manage_file_content}",
      data => {
        "${title}" => {
          acl       => $acl,
          #usmuser   => $title,
          secmode   => $secmode,
        },
      },
  }

  exec { "create_auth_user_${title}":
    user     => 'root',
    command  => "service ${snmpd::service_name} stop ; echo \"${createcmd}\" >>${snmpd::params::var_net_snmp}/snmpd.conf",
    unless   => $check_usm_user_exists,
    require  => File['var_net_snmp'],
  }
}
