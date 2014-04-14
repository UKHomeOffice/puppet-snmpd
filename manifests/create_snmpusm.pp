# == Define: create_snmpusm
#
# Description:
#
# === Parameters
#
#
# === Examples
#
# === Authors
#
# === Copyright
#
define snmpd::create_snmpusm (
  $authtype = 'SHA',
  $privtype = 'AES',
  $authpass = '',
  $privpass = '',
  $acl      = 'rouser',
  $secmode  = 'noauth',
) {

  include snmpd
  include snmpd::params

  validate_re($secmode,'^noauth$|^auth$|^priv$')
  validate_re($acl,'^rouser$|^rwuser$')

  # Check to see that authpass and privpass are 8 characters or more long
  if size($authpass) < 8 {
    fail('passphrase chosen is below the length requirements - min: 8')
  }

  if $privpass and size($privpass) < 8 {
    fail('passphrase chosen is below the length requirements - min: 8')
  }

  if $privpass {
    $createcmd = "createUser ${title} ${authtype} ${authpass} ${privtype} ${privpass}"
  } else {
    $createcmd = "createUser ${title} ${authtype} ${authpass}"
  }

  $check_usm_user_exists = "awk \'/^usmUser/ {print \$5}\' ${snmpd::params::var_net_snmp}/snmpd.conf | xxd -r -p | grep ${title} > /dev/null 2>&1"

  if $snmpd::config_file {
    datacat_fragment {"var_net_snmp_${title}":
      target => $snmpd::config_file,
        data => {
          usmuser => [{
            acl     => $acl,
            secmode => $secmode,
            user    => $title,
          }],
        },
    }

    exec {"create_auth_user_${title}":
      path    => '/bin:/usr/bin:/sbin:/usr/sbin',
      user    => 'root',
      command => "/etc/init.d/${snmpd::service_name} stop && echo \"${createcmd}\" >> ${snmpd::params::var_net_snmp}/snmpd.conf",
      unless  => $check_usm_user_exists,
    }

    Package[$snmpd::package_name] -> Datacat_fragment["var_net_snmp_${title}"] -> Exec["create_auth_user_${title}"]
  }
}
