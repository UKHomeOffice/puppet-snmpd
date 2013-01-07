require 'spec_helper'

describe 'snmpd', :type => :class do
  context 'ensure package is installed' do
    it {
      should contain_package('net-snmp').with({'ensure' => 'installed'})
    }
  end
  
  context 'ensure snmpv3 user in database' do
    it {
      should contain_exec('snmpv3-user-icingamonitor').with(
                                                  'command' => '/usr/sbin/service snmpd stop && \
/usr/bin/net-snmp-create-v3-user -ro \
-A "9QZeqv+1x9Jx6Epkx]9FN9iw%um" -X "9QZeqv+1x9Jx6Epkx]9FN9iw%um" \
-a SHA -x AES icingamonitor && \
/usr/sbin/service snmpd start',
                                                  'unless' => '/bin/grep "0x6963696e67616d6f6e69746f7200" \
/var/lib/net-snmp/snmpd.conf'
                                                  )
    }
  end
  
  context 'ensure the snmpd daemon is running and enabled' do
    it {
      should contain_service('snmpd').with(
                                           'ensure' => 'running',
                                           'enable' => 'true'
                                           )
    }
  end
  
  context 'ensure the snmpd daemon is refreshed on config file change' do
    it {
      notify = catalogue.resource('file','snmpd.conf').send(:parameters)[:notify]
            notify.send(:name).should eq('Service/snmpd')
    }
  end
  
  context 'ensure that config entries in place' do
    it {
      should contain_file('snmpd.conf').with(
                                            'ensure' => 'file',
                                            'owner' => 'root',
                                            'group' => 'root',
                                            'source' => 'puppet:///modules/snmpd.conf',
                                            'path' => '/etc/snmp/snmpd.conf',
                                            'mode' => '0664'
                                            )
    }
  end
end