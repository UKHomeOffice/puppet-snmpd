#
# Defines a snmpd user
#
define snmpd::create_user (
  $authtype = 'SHA',
  $privtype = 'AES',
  $authpass = '',
  $privpass = '',
)  {
  include snmpd

  if $privpass {
    $createcmd = "createUser ${title} ${authtype} ${authpass} ${privtype} ${privpass}"
  } else {
    $createcmd = "createUser ${title} ${authtype} ${authpass}"
  }
  file { 'var_net_snmp':
    ensure    => 'directory',
    path      => $snmpd::config_file,
    mode      => $snmpd::config_file_mode,
    owner     => $snmpd::config_file_owner,
    group     => $snmpd::config_file_group,
    require   => $require_package,
  }

  exec { "create_auth_user_${title}":
    user     => 'root',
    command  => "service ${service_name} stop ; echo \"${createcmd}\" >>${snmp::params::var_net_snmp}/${daemon}.conf && touch ${snmp::params::var_net_snmp}/${title}",
    creates  => "${snmp::params::var_net_snmp}/${title}",
    require  => [ $require_package, File['var_net_snmp'], ],
  }
}
