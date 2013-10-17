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

  $check_usm_user_exists = "awk \'/^usmUser/ {print \$5}\' ${snmpd::params::var_net_snmp}/snmpd.conf | xxd -r -p | /bin/grep ${title} > /dev/null 2>&1"

  datacat_fragment {"var_net_snmp_${title}":
    target => "${snmpd::config_file}",
      data => {
        usmuser => [ {
          acl     => $acl,
          user    => $title,
          secmode => $secmode,
        } ],
      },
  }

  exec { "create_auth_user_${title}":
    path     => '/usr/bin:/usr/sbin:/bin',
    user     => 'root',
    command  => "service ${snmpd::service_name} stop ; echo \"${createcmd}\" >>${snmpd::params::var_net_snmp}/snmpd.conf",
    unless   => $check_usm_user_exists,
    require  => Datacat_fragment["var_net_snmp_${title}"],
  }
}
