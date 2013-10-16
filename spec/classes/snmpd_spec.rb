require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'snmpd' do

  let(:title) { 'snmpd' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) { { :ipaddress => '10.42.42.42' } }
  let(:params) { {:template => "snmpd/spec.erb"} }

  describe 'Test standard installation' do
    it { should contain_package('snmpd').with_ensure('present') }
    it { should contain_service('snmpd').with_ensure('running') }
    it { should contain_service('snmpd').with_enable('true') }
    it { should contain_datacat('snmpd.conf').with_path('/etc/snmp/snmpd.conf') }
  end

  describe 'Test installation of a specific version' do
    let(:params) { {:version => '1.0.42' } }
    it { should contain_package('snmpd').with_ensure('1.0.42') }
  end

  describe 'Test decommissioning - uninstall' do
    let(:params) { {:uninstall => true, :port => '42'} }

    it 'should remove Package[snmpd]' do should contain_package('snmpd').with_ensure('absent') end 
    it 'should stop Service[snmpd]' do should contain_service('snmpd').with_ensure('stopped') end
    it 'should not enable at boot Service[snmpd]' do should contain_service('snmpd').with_enable('false') end
  end

  describe 'Test decommissioning - disable' do
    let(:params) { {:disable => true, :port => '42'} }

    it { should contain_package('snmpd').with_ensure('present') }
    it 'should stop Service[snmpd]' do should contain_service('snmpd').with_ensure('stopped') end
    it 'should not enable at boot Service[snmpd]' do should contain_service('snmpd').with_enable('false') end
  end

  describe 'Test decommissioning - disableboot' do
    let(:params) { {:disableboot => true, :port => '42'} }
  
    it { should contain_package('snmpd').with_ensure('present') }
    it { should_not contain_service('snmpd').with_ensure('present') }
    it { should_not contain_service('snmpd').with_ensure('absent') }
    it 'should not enable at boot Service[snmpd]' do should contain_service('snmpd').with_enable('false') end
    it { should contain_datacat('snmpd.conf').with_path('/etc/snmp/snmpd.conf') }
  end 
=begin 
  describe 'Test customizations - source' do
    let(:params) { {:source => "puppet://modules/snmpd/spec" , :source_dir => "puppet://modules/snmpd/dir/spec" , :source_dir_purge => true } }

    it 'should request a valid source ' do
      content = catalogue.resource('file', 'snmpd.conf').send(:parameters)[:source]
      content.should == "puppet://modules/snmpd/spec"
    end
    it 'should request a valid source dir' do
      content = catalogue.resource('file', 'snmpd.dir').send(:parameters)[:source]
      content.should == "puppet://modules/snmpd/dir/spec"
    end
    it 'should purge source dir if source_dir_purge is true' do
      content = catalogue.resource('file', 'snmpd.dir').send(:parameters)[:purge]
      content.should == true
    end
  end
=end 

  describe 'Test service autorestart' do
    it { should contain_datacat('snmpd.conf').with_notify('Service[snmpd]') }
  end

  describe 'Test service autorestart' do
    let(:params) { {:service_autorestart => "no" } }

    it 'should not automatically restart the service, when service_autorestart => false' do
      content = catalogue.resource('datacat', 'snmpd.conf').send(:parameters)[:notify]
      content.should be_nil
    end
  end

end

