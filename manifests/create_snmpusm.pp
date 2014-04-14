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
define itv_snmpd_hiera::create_snmpusm (
  $authtype = 'SHA',
  $privtype = 'AES',
  $authpass = '',
  $privpass = '',
  $acl      = 'rouser',
  $secmode  = 'noauth',
) {

  include itv_snmpd_hiera
  include itv_snmpd_hiera::params

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

  $check_usm_user_exists = "awk \'/^usmUser/ {print \$5}\' ${itv_snmpd_hiera::params::var_net_snmp}/snmpd.conf | xxd -r -p | grep ${title} > /dev/null 2>&1"

  if $itv_snmpd_hiera::config_file {
    datacat_fragment {"var_net_snmp_${title}":
      target => $itv_snmpd_hiera::config_file,
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
      command => "/etc/init.d/${itv_snmpd_hiera::service_name} stop && echo \"${createcmd}\" >> ${itv_snmpd_hiera::params::var_net_snmp}/snmpd.conf",
      unless  => $check_usm_user_exists,
    }

    Package[$itv_snmpd_hiera::package_name] -> Datacat_fragment["var_net_snmp_${title}"] -> Exec["create_auth_user_${title}"]
  }
}
