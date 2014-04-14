# == Class: itv_snmpd::params
# This class defines default parameters used by the main modules class snmpd
# Operating Systems differences in names and paths are addressed here
#
# === Variables
#
# Refer to snmpd class for the variables defined here.
#
# === Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class itv_snmpd_hiera::params {

  $package_name = $::osfamily ? {
    /(?i:RedHat)/ => 'net-snmp',
    default              => 'snmpd'
  }

  $service_name = $::osfamily ? {
    default => 'snmpd',
  }

  $config_dir = $::osfamily ? {
    default => '/etc/snmp'
  }

  $config_file = $::osfamily ? {
    default => "${config_dir}/snmpd.conf"
  }

  $config_file_owner = $::osfamily ? {
    default => 'root'
  }

  $config_file_group = $::osfamily ? {
    default => 'root'
  }

  $config_file_template = 'itv_snmpd_hiera/snmpd.conf.erb'

  $config_file_mode = $::osfamily ? {
    default => '0644'
  }

  $var_net_snmp = $::osfamily ? {
    /(?i:RedHat|CentOS)/ => $::lsbmajdistrelease ? {
      '5'      => '/var/net-snmp',
       default => '/var/lib/net-snmp'
    },
    default => '/var/lib/net-snmp'
  }
}
