require 'spec_helper'

describe 'wsus_client' do
  let(:reg_type) { 'dword' }
  let(:enabled_bit) { 1 }
  let(:reg_ensure) { 'present' }

  test_hash = {
    '2012' => {:base_key => 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate',                                     
               :au_key => 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU'},
    '2008' => {:base_key => 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate',
               :au_key => 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU'}
  }

  shared_examples 'registry_value' do
    it {
      should contain_registry_value(reg_key).with(
               {
                 'ensure' => reg_ensure,
                 'type'   => reg_type,
                 'data'   => reg_data,
               }
             )
    }
  end

  shared_examples 'registry_value undefined' do
    it { should_not contain_registry_value(reg_key) }
  end

  shared_examples 'fail validation' do
    it {
      expect { catalogue }.to raise_error(Puppet::Error, error_message)
    }
  end

  shared_examples 'valid range' do |range = []|
    range.each do |int|
      describe "#{int}" do
        let(:params) { {
          param_sym => int,
        } }
        let(:reg_data) { int }
        it_behaves_like 'registry_value'
      end
    end
  end

  shared_examples 'below range' do
    let(:params) { {param_sym => below_range} }
    let(:error_message) { /Expected #{below_range} to be greater or equal to \d, got #{below_range}/ }
    it {
      expect { catalogue }.to raise_error(Puppet::Error, error_message)
    }
  end

  shared_examples 'above range' do
    let(:params) { {param_sym => above_range} }
    let(:error_message) { /Expected #{above_range} to be less or equal to \d+, got #{above_range}/ }
    it {
      expect { catalogue }.to raise_error(Puppet::Error, error_message)
    }
  end

  shared_examples 'bool value' do
    [true, false].each do |v|
      describe "#{v}" do
        let(:params) { {
          param_sym => v,
        } }
        let(:reg_data) { v ? 1 : 0 }
        it_behaves_like 'registry_value'
      end
    end
    describe 'unset when undef' do
      it { should_not contain_registry_value(reg_key) }
    end
  end

  shared_examples 'enabled feature' do |valid_non_bool_value|
    describe 'unset when undef' do
      it { should_not contain_registry_value("#{reg_key}Enabled") }
      it { should_not contain_registry_value(reg_key) }
    end
    [true, false].each do |enabled|
      describe "#{enabled}" do
        let(:params) { {param_sym => enabled} }
        it {
          should contain_registry_value("#{reg_key}Enabled").with(
                   {
                     'type' => 'dword',
                     'data' => (enabled ? 1 : 0)
                   })
        }
        it { should_not contain_registry_value(reg_key) }
      end
    end
    describe "enabled as set with #{valid_non_bool_value}" do
      let(:params) { {param_sym => valid_non_bool_value} }
      it { should contain_registry_value("#{reg_key}Enabled") }
      it { should contain_registry_value(reg_key).with(
                    {
                      'data' => valid_non_bool_value
                    }) }
    end
  end

  shared_examples 'non enabled feature' do |valid_value = true|
    let(:params) { {param_sym => valid_value} }
    it { should_not contain_registry_value("#{reg_key}Enabled") }
  end

  test_hash.each do |os, settings|
    context "Windows #{os}" do
      let(:facts) { {
        :operatingsystem => 'windows',
        :operatingsystemrelease => "Server #{os}"
      } }

      base_key = settings[:base_key]
      au_key = settings[:au_key]
      context 'base keys' do
        [true, false].each do |purge|
          describe "purge_values => #{purge}" do
            let(:params) { {:purge_values => purge} }
            [base_key, au_key].each do |key|
              it {
                should contain_registry_key(key).with(
                         {
                           'purge_values' => purge
                         })
              }
            end
          end
        end
      end

      context "server_url =>" do
        let(:reg_type) { 'string' }
        let(:reg_data) { 'https://SERVER:8530' }

        describe 'WUServer setting' do
          let(:params) { {
            :server_url => 'https://SERVER:8530'
          } }
          it_behaves_like 'non enabled feature', 'https://SERVER:8530' do
            let(:param_sym) { :server_url }
            let(:reg_key) { "#{base_key}\\WUServer" }
          end
          it_behaves_like 'registry_value' do
            let(:reg_key) { "#{base_key}\\WUServer" }
          end
          it_behaves_like 'registry_value undefined' do
            let(:reg_key) { "#{base_key}\\WUStatusServer" }
          end
          it_behaves_like 'registry_value' do
            let(:reg_key) { "#{au_key}\\UseWUServer" }
            let(:reg_data) { 1 }
            let(:reg_type) { 'dword' }
          end
        end
        describe 'WUStatusServer =>' do
          describe 'true' do
            let(:params) { {
              :server_url => 'https://SERVER:8530',
              :enable_status_server => true,
            } }
            it_behaves_like 'registry_value' do
              let(:reg_key) { "#{base_key}\\WUServer" }
            end
            it_behaves_like 'registry_value' do
              let(:reg_key) { "#{base_key}\\WUStatusServer" }
            end
            it_behaves_like 'registry_value' do
              let(:reg_key) { "#{au_key}\\UseWUServer" }
              let(:reg_data) { 1 }
              let(:reg_type) { 'dword' }
            end
          end
          describe 'false' do
            let(:params) { {
              :server_url => 'https://SERVER:8530',
              :enable_status_server => false,
            } }
            it_behaves_like 'registry_value' do
              let(:reg_key) { "#{base_key}\\WUServer" }
            end
            it_behaves_like 'registry_value' do
              let(:reg_key) { "#{base_key}\\WUStatusServer" }
              let(:reg_ensure) { 'absent' }
            end
            it_behaves_like 'registry_value' do
              let(:reg_key) { "#{au_key}\\UseWUServer" }
              let(:reg_data) { 1 }
              let(:reg_type) { 'dword' }
            end
          end
        end
      end

      context 'auto_update_option =>' do
        let(:reg_key) { "#{au_key}\\AUOptions" }
        let(:param_sym) { :auto_update_option }
        it_behaves_like 'valid range', [2, 3, 5]
        it_behaves_like 'non enabled feature', 2
        [1, 6].each do |au_opt|
          describe "#{au_opt}" do
            let(:params) { {
              :auto_update_option => au_opt,
            } }
            let(:error_message) { /Valid options for auto_update_option are 2|3|4|5, provided #{au_opt}/ }
            it_behaves_like 'fail validation'
          end
        end
        ['Scheduled', 4].each do |param|
          describe 'require scheduled_install_day scheduled_install_hour' do
            let(:params) { {
              :auto_update_option => param,
            } }
            let(:error_message) { /scheduled_install_day and scheduled_install_hour required when specifying auto_update_option => \'#{param}\'/ }
            it_behaves_like 'fail validation'
            it_behaves_like 'fail validation' do
              let(:params) { {
                :auto_update_option => param,
                :scheduled_install_day => 4,
              } }
            end
          end
        end
      end

      context 'accept_trusted_publisher_certs =>' do
        let(:reg_key) { "#{base_key}\\AcceptTrustedPublisherCerts" }
        let(:param_sym) { :accept_trusted_publisher_certs }
        it_behaves_like 'bool value'
        it_behaves_like 'registry_value undefined'
        it_behaves_like 'non enabled feature'
      end

      context 'accept_trusted_publisher_certs =>' do
        let(:reg_key) { "#{base_key}\\AcceptTrustedPublisherCerts" }
        let(:param_sym) { :accept_trusted_publisher_certs }
        it_behaves_like 'bool value'
        it_behaves_like 'registry_value undefined'
        it_behaves_like 'non enabled feature'
      end

      context 'auto_install_minor_updates =>' do
        let(:reg_key) { "#{au_key}\\AutoInstallMinorUpdates" }
        let(:param_sym) { :auto_install_minor_updates }
        it_behaves_like 'bool value'
        it_behaves_like 'registry_value undefined'
        it_behaves_like 'non enabled feature'
      end

      context 'detection_frequency_hours =>' do
        let(:reg_key) { "#{au_key}\\DetectionFrequency" }
        let(:below_range) { 0 }
        let(:above_range) { 23 }
        let(:param_sym) { :detection_frequency_hours }
        it_behaves_like 'valid range', [1, 11, 22]
        it_behaves_like 'below range'
        it_behaves_like 'above range'
        it_behaves_like 'enabled feature', 11
      end

      context 'disable_windows_update_access =>' do
        let(:reg_key) { "#{base_key}\\DisableWindowsUpdateAccess" }
        let(:param_sym) { :disable_windows_update_access }
        it_behaves_like 'bool value'
        it_behaves_like 'non enabled feature'
      end

      context 'elevate_non_admins =>' do
        let(:reg_key) { "#{base_key}\\ElevateNonAdmins" }
        let(:param_sym) { :elevate_non_admins }
        it_behaves_like 'bool value'
        it_behaves_like 'non enabled feature'
      end

      context 'no_auto_reboot_with_logged_on_users =>' do
        let(:reg_key) { "#{au_key}\\NoAutoRebootWithLoggedOnUsers" }
        let(:param_sym) { :no_auto_reboot_with_logged_on_users }
        it_behaves_like 'bool value'
        it_behaves_like 'non enabled feature'
      end

      context 'no_auto_update =>' do
        let(:reg_key) { "#{au_key}\\NoAutoUpdate" }
        let(:param_sym) { :no_auto_update }
        it_behaves_like 'bool value'
        it_behaves_like 'non enabled feature'
      end

      context 'reboot_relaunch_timeout_minutes =>' do
        let(:reg_key) { "#{au_key}\\RebootRelaunchTimeout" }
        let(:below_range) { 0 }
        let(:above_range) { 1441 }
        let(:param_sym) { :reboot_relaunch_timeout_minutes }
        it_behaves_like 'valid range', [1, 720, 1440]
        it_behaves_like 'below range'
        it_behaves_like 'above range'
        it_behaves_like 'enabled feature', 720
      end

      context 'reboot_warning_timeout_minutes =>' do
        let(:reg_key) { "#{au_key}\\RebootWarningTimeout" }
        let(:below_range) { 0 }
        let(:above_range) { 31 }
        let(:param_sym) { :reboot_warning_timeout_minutes }
        it_behaves_like 'valid range', [1, 15, 30]
        it_behaves_like 'below range'
        it_behaves_like 'above range'
        it_behaves_like 'enabled feature', 15
      end

      context 'reschedule_wait_time_minutes =>' do
        let(:reg_key) { "#{au_key}\\RescheduleWaitTime" }
        let(:below_range) { 0 }
        let(:above_range) { 61 }
        let(:param_sym) { :reschedule_wait_time_minutes }
        it_behaves_like 'valid range', [1, 31, 60]
        it_behaves_like 'below range'
        it_behaves_like 'above range'
        it_behaves_like 'enabled feature', 30
      end

      context 'scheduled_install_day =>' do
        let(:reg_key) { "#{au_key}\\ScheduledInstallDay" }
        let(:param_sym) { :scheduled_install_day }
        let(:above_range) { 8 }
        it_behaves_like 'valid range', [0, 4, 7]
        it_behaves_like 'registry_value undefined' #when unset should be missing
        it_behaves_like 'non enabled feature', 4
        days = %w(Everyday Sunday Monday Tuesday Wednesday Thursday Friday Saturday)
        (0..7).each do |day_int|
          describe "convert #{days[day_int]}" do
            let(:params) { {param_sym => days[day_int]} }
            let(:reg_data) { day_int }
            it_behaves_like 'registry_value'
          end
        end
      end

      context 'scheduled_install_hour =>' do
        let(:reg_key) { "#{au_key}\\ScheduledInstallTime" }
        let(:above_range) { 24 }
        let(:param_sym) { :scheduled_install_hour }
        it_behaves_like 'valid range', [0, 12, 23]
        it_behaves_like 'above range'
        it_behaves_like 'registry_value undefined' #when unset should be missing
        it_behaves_like 'non enabled feature', 12
      end

      context 'target_group =>' do
        let(:reg_key) { "#{base_key}\\TargetGroup" }
        let(:param_sym) { :target_group }
        it_behaves_like 'enabled feature', 'UberUserGroup'
      end
    end
  end
end
