# Class: snmpd
#
# This module manages snmpd
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class snmpd {

package {'net-snmp':
  ensure => 'installed'
}

exec {'snmpv3-user-icingamonitor':
  command   => '/sbin/service snmpd stop && \
/usr/bin/net-snmp-create-v3-user -ro \
-A "9QZeqv+1x9Jx6Epkx]9FN9iw%um" -X "9QZeqv+1x9Jx6Epkx]9FN9iw%um" \
-a SHA -x AES icingamonitor && \
/sbin/service snmpd start',
  unless    => '/bin/grep "0x6963696e67616d6f6e69746f7200" \
/var/lib/net-snmp/snmpd.conf'
}

file {'snmpd.conf':
  ensure  => 'file',
  owner   => 'root',
  group   => 'root',
  mode    => '0664',
  source  => 'puppet:///modules/snmpd.conf',
  path    => '/etc/snmp/snmpd.conf',
  notify  => Service['snmpd']
}

service {'snmpd':
  ensure => 'running',
  enable => true
}

}
