require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'snmpd' do

  let(:title) { 'snmpd' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) { { :ipaddress => '10.42.42.42' } }

  describe 'Test standard installation' do
    it { should contain_package('snmpd').with_ensure('present') }
    it { should contain_service('snmpd').with_ensure('running') }
    it { should contain_service('snmpd').with_enable('true') }
    it { should contain_file('snmpd.conf').with_ensure('present') }
  end

  describe 'Test installation of a specific version' do
    let(:params) { {:version => '1.0.42' } }
    it { should contain_package('snmpd').with_ensure('1.0.42') }
  end

  describe 'Test decommissioning - absent' do
    let(:params) { {:absent => true} }

    it 'should remove Package[snmpd]' do should contain_package('snmpd').with_ensure('absent') end 
    it 'should stop Service[snmpd]' do should contain_service('snmpd').with_ensure('stopped') end
    it 'should not enable at boot Service[snmpd]' do should contain_service('snmpd').with_enable('false') end
    it 'should remove snmpd configuration file' do should contain_file('snmpd.conf').with_ensure('absent') end
  end

  describe 'Test decommissioning - disable' do
    let(:params) { {:disable => true} }

    it { should contain_package('snmpd').with_ensure('present') }
    it 'should stop Service[snmpd]' do should contain_service('snmpd').with_ensure('stopped') end
    it 'should not enable at boot Service[snmpd]' do should contain_service('snmpd').with_enable('false') end
    it { should contain_file('snmpd.conf').with_ensure('present') }
  end

  describe 'Test decommissioning - disableboot' do
    let(:params) { {:disableboot => true} }
  
    it { should contain_package('snmpd').with_ensure('present') }
    it { should_not contain_service('snmpd').with_ensure('present') }
    it { should_not contain_service('snmpd').with_ensure('absent') }
    it 'should not enable at boot Service[snmpd]' do should contain_service('snmpd').with_enable('false') end
    it { should contain_file('snmpd.conf').with_ensure('present') }
  end 

  describe 'Test customizations - template' do
    let(:params) { {:template => "snmpd/spec.erb" , :options => { 'opt_a' => 'value_a' } } }

    it 'should generate a valid template' do
      content = catalogue.resource('file', 'snmpd.conf').send(:parameters)[:content]
      content.should match "fqdn: rspec.example42.com"
    end
    it 'should generate a template that uses custom options' do
      content = catalogue.resource('file', 'snmpd.conf').send(:parameters)[:content]
      content.should match "value_a"
    end
  end

  describe 'Test customizations - content' do
    let(:params) { {:content => "Rspec" } }

    it 'should generate a valid template' do
      content = catalogue.resource('file', 'snmpd.conf').send(:parameters)[:content]
      content.should match "Rspec"
    end
  end

  describe 'Test customizations - template is preferred over content' do
    let(:params) { {:content => "Rspec" , :template => "snmpd/spec.erb" , :options => { 'opt_a' => 'value_a' } } }

    it 'should generate a valid template' do
      content = catalogue.resource('file', 'snmpd.conf').send(:parameters)[:content]
      content.should match "value_a"
    end
  end

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

  describe 'Test customizations - custom class' do
    let(:params) { {:my_class => "snmpd::spec" } }
    it 'should automatically include a custom class' do
      content = catalogue.resource('file', 'snmpd.conf').send(:parameters)[:content]
      content.should match "fqdn: rspec.example42.com"
    end
  end

  describe 'Test service autorestart' do
    it { should contain_file('snmpd.conf').with_notify('Service[snmpd]') }
  end

  describe 'Test service autorestart' do
    let(:params) { {:service_autorestart => "no" } }

    it 'should not automatically restart the service, when service_autorestart => false' do
      content = catalogue.resource('file', 'snmpd.conf').send(:parameters)[:notify]
      content.should be_nil
    end
  end

end

