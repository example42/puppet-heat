require 'spec_helper'

describe 'heat::generic_service', :type => :define do

  let(:title) { 'heat-registry' }

  context 'Supported OS - ' do
    ['Debian', 'RedHat'].each do |osfamily|
      describe "#{osfamily} standard installation" do
        let(:params) {{  }}
        let(:facts) {{
          :osfamily => osfamily,
        }}
        it { should contain_package('heat-registry').with_ensure('present') }
        it { should contain_service('heat-registry').with_ensure('running') }
      end

      describe "#{osfamily} installation of a specific package version" do
        let(:params) { {
          :package_ensure => '1.0.42',
        } }
        let(:facts) {{
          :osfamily => osfamily,
        }}
        it { should contain_package('heat-registry').with_ensure('1.0.42') }
      end

      describe "#{osfamily} removal of package installation" do
        let(:params) { {
          :package_ensure => 'absent',
        } }
        let(:facts) {{
          :osfamily => osfamily,
        }}
        it 'should remove Package[heat-registry]' do should contain_package('heat-registry').with_ensure('absent') end
        it 'should stop Service[heat-registry]' do should contain_service('heat-registry').with_ensure('stopped') end
        it 'should not manage at boot Service[heat-registry]' do should contain_service('heat-registry').with_enable(nil) end
      end

      describe "#{osfamily} service disabling" do
        let(:params) { {
          :service_ensure => 'stopped',
          :service_enable => false,
        } }
        let(:facts) {{
          :osfamily => osfamily,
        }}
        it 'should stop Service[heat-registry]' do should contain_service('heat-registry').with_ensure('stopped') end
        it 'should not enable at boot Service[heat-registry]' do should contain_service('heat-registry').with_enable('false') end
      end

      describe "#{osfamily} configuration via custom template" do
        let(:params) { {
          :config_file_template     => 'heat/spec.conf',
          :config_file_options_hash => { 'opt_a' => 'value_a' },
        } }
        let(:facts) {{
          :osfamily => osfamily,
        }}
        it { should contain_file('heat-registry.conf').with_content(/This is a template used only for rspec tests/) }
        it 'should generate a template that uses custom options' do
          should contain_file('heat-registry.conf').with_content(/value_a/)
        end
      end

      describe "#{osfamily} configuration via custom content" do
        let(:params) { {
          :config_file_content    => 'my_content',
        } }
        let(:facts) {{
          :osfamily => osfamily,
        }}
        it { should contain_file('heat-registry.conf').with_content(/my_content/) }
      end

      describe "#{osfamily} configuration via custom source file" do
        let(:params) { {
          :config_file_source => "puppet:///modules/heat/spec.conf",
        } }
        let(:facts) {{
          :osfamily => osfamily,
        }}
        it { should contain_file('heat-registry.conf').with_source('puppet:///modules/heat/spec.conf') }
      end

      describe "#{osfamily} service restart on config file change (default)" do
        let(:facts) {{
          :osfamily => osfamily,
        }}
        let(:params) { {
          :config_file_content => 'my_content',
        } }
        it 'should automatically restart the service when files change' do
          should contain_file('heat-registry.conf').with_notify('Service[heat-registry]')
        end
      end

      describe "#{osfamily} service restart disabling on config file change" do
        let(:params) { {
          :config_file_notify  => '',
          :config_file_content => 'my_content',
        } }
        let(:facts) {{
          :osfamily => osfamily,
        }}
        it 'should automatically restart the service when files change' do
          should contain_file('heat-registry.conf').without_notify
        end
      end

    end
  end

end

