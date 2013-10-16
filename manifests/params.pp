# Class: snmpd::params
#
# This class defines default parameters used by the main module class snmpd
# Operating Systems differences in names and paths are addressed here
#
# == Variables
#
# Refer to snmpd class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class snmpd::params {

  $snmpname = $::fqdn
  $snmplocation = 'Server Room'
  $snmpcontact = 'root@localhost'

  ### Application related parameters

  $package = $::operatingsystem ? {
    /(?i:RedHat|Centos|Amazon)/ => 'net-snmp',
    default                     => 'snmpd',
  }

  $service = $::operatingsystem ? {
    default        => 'snmpd',
  }

  $service_status = $::operatingsystem ? {
    default => true,
  }

  $process = $::operatingsystem ? {
    default => 'snmpd',
  }

  $process_args = $::operatingsystem ? {
    default => '',
  }

  $process_user = $::operatingsystem ? {
    default => 'root',
  }

  $config_dir = $::operatingsystem ? {
    default         => '/etc/snmpd',
  }

  $config_file = $::operatingsystem ? {
    default         => '/etc/snmp/snmpd.conf',
  }

  $config_file_mode = $::operatingsystem ? {
    default               => '0644',
  }

  $config_file_owner = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_group = $::operatingsystem ? {
    default        => 'root',
  }

  $config_file_init = $::operatingsystem ? {
    /(?i:RedHat|Centos|Amazon)/ => '/etc/sysconfig/snmpd.options',
    default                     => '/etc/sysconfig/snmpd',
  }

  $pid_file = $::operatingsystem ? {
    default => '/var/run/snmpd.pid',
  }

  $data_dir = $::operatingsystem ? {
    default => '',
  }

  $log_dir = $::operatingsystem ? {
    default => '',
  }

  $log_file = $::operatingsystem ? {
    default => '',
  }

  $var_net_snmp = '/var/lib/net-snmp'

  $port = '161'
  $protocol = 'udp'

  # General Settings
  $source = ''
  $source_dir = ''
  $source_dir_purge = false
  $template = 'snmpd/snmpd.conf.erb'
  $content = ''
  $options = ''
  $users  = ''
  $service_autorestart = true
  $version = 'present'
  $absent = false
  $disable = false
  $disableboot = false

  ### General module variables that can have a site or per module default
  $debug = false
  $audit_only = false

}
