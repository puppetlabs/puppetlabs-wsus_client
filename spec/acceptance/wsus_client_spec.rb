require 'spec_helper_acceptance'
RSpec.describe 'wsus_client' do

  let(:reg_type) { :type_dword_converted }

  base_key = 'HKLM\\Software\\Policies\\Microsoft\\Windows\\WindowsUpdate'
  au_key = "#{base_key}\\AU"

  def clear_registry
    pp = <<-PP
service {'wuauserv':
  ensure => stopped,
}->
registry_key{'HKLM\\Software\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU':
  ensure       => absent,
  purge_values => true,
}->
registry_key{'HKLM\\Software\\Policies\\Microsoft\\Windows\\WindowsUpdate':
  ensure       => absent,
  purge_values => true,
}
    PP
    apply_manifest_on(default, pp, :catch_failures => false)
  end

  def create_apply_manifest(params, clear_first = true)
    if clear_first
      clear_registry
    end
    pp = "class {'wsus_client':"
    params.each { |k, v|
      v = "'#{v}'" if v.is_a? String
      pp << "\n  #{k.to_s} => #{v},"
    }
    pp << "}"
    apply_manifest_on(default, pp, :catch_failures => true)
  end


  shared_examples 'registry_value' do |property, key = base_key|
    describe windows_registry_key(key) do
      it { should exist }
      it {
        if !reg_data.nil?
          should have_property_value(property, reg_type, reg_data)
        end
        should have_property(property, reg_type)
      }
    end
  end

  shared_examples 'registry_value undefined' do |property, key = base_key|
    describe windows_registry_key(key) do
      it { should_not have_property(property, reg_type) }
    end
  end

  shared_examples 'boolean values' do |param, property, key = base_key|
    [true, false].each do |enabled|
      describe "#{enabled}" do
        it { create_apply_manifest param => enabled }
        let(:reg_data) { enabled ? 1 : 0 }
        it_behaves_like 'registry_value', property, key
      end
    end
  end

  shared_examples 'enabled range' do |param, property, array_range, key = base_key|

    array_range.each do |valid_value|
      describe "#{valid_value}" do
        before :all do
          create_apply_manifest param => valid_value
        end
        describe windows_registry_key(key) do
          it { should exist }
          it { should have_property_value(property, :type_dword_converted, valid_value) }
          it { should have_property_value("#{property}Enabled", :type_dword_converted, 1) }
        end
      end
    end

    describe 'false' do
      it { create_apply_manifest param => false }
      describe windows_registry_key(key) do
        it { should exist }
        it { should have_property_value("#{property}Enabled", :type_dword_converted, 0) }
      end
    end
  end

  context "server_url =>", {:testrail => ['70183', '70185', '70184']} do
    let(:reg_type) { :type_string }

    ['http://SERVER:8530', 'https://SERVER:8531'].each do |wsus_url|
      describe wsus_url do
        let(:reg_data) { wsus_url }
        it { create_apply_manifest :server_url => wsus_url }
        it_behaves_like 'registry_value', "WUServer"
        it_behaves_like 'registry_value undefined', "WUStatusServer"
        it_behaves_like 'registry_value', "UseWUServer", au_key do
          let(:reg_data) { 1 }
          let(:reg_type) { :type_dword_converted }
        end
      end
    end

    describe "true", {:testrail => ['70189']} do
      let(:reg_data) { 'http://myserver:8530' }
      it { create_apply_manifest(
          {:server_url => 'http://myserver:8530',
           :enable_status_server => true,
          }) }
      it_behaves_like 'registry_value', "WUStatusServer"
      it_behaves_like 'registry_value', "WUServer"
    end

    describe "false", {:testrail => ['70190']} do
      let(:reg_data) { 'http://myserver:8530' }
      it { create_apply_manifest(
          {:server_url => 'http://myserver:8530',
           :enable_status_server => false,
          }, false) }
      it_behaves_like 'registry_value undefined', "WUStatusServer"
      it_behaves_like 'registry_value', "WUServer"
    end
  end

  context 'auto_update_option =>' do
    {'notifyonly' => 2,
     'autonotify' => 3,
     'autoinstall' => 5}.each do |key, au_opt|
      describe "#{au_opt}", {:testcase => ['70197', '70198', '70200']} do
        it { create_apply_manifest :auto_update_option => au_opt }
        it_behaves_like 'registry_value', 'AUOptions', au_key do
          let(:reg_data) { au_opt }
        end
      end
      describe "#{key}", {:testcase => ['70201', '70202', '70204']} do
        it { create_apply_manifest :auto_update_option => key }
        it_behaves_like 'registry_value', 'AUOptions', au_key do
          let(:reg_data) { au_opt }
        end
      end
    end
    ['Scheduled', 4].each do |scheduled|
      describe 'Scheduled', {:testrail => ['70203', '70199']} do
        it { create_apply_manifest(
            {:auto_update_option => scheduled,
             :scheduled_install_day => 0,
             :scheduled_install_hour => 19, }) }
        it_behaves_like 'registry_value', 'AUOptions', au_key do
          let(:reg_data) { 4 }
        end
        it_behaves_like 'registry_value', 'ScheduledInstallDay', au_key do
          let(:reg_data) { 0 }
        end
        it_behaves_like 'registry_value', 'ScheduledInstallTime', au_key do
          let(:reg_data) { 19 }
        end
      end
    end
  end

  context 'accept_trusted_publisher_certs =>', {:testrail => ['70193', '70194']} do
    it_behaves_like 'boolean values',
                    :accept_trusted_publisher_certs,
                    'AcceptTrustedPublisherCerts'
  end


  context 'auto_install_minor_updates =>', {:testrail => ['70210', '70211']} do
    it_behaves_like 'boolean values',
                    :auto_install_minor_updates,
                    'AutoInstallMinorUpdates', au_key
  end

  context 'detection_frequency_hours =>', {:testrail => ['70213', '70214', '70215']} do
    it_behaves_like 'enabled range',
                    :detection_frequency_hours,
                    'DetectionFrequency',
                    [1, 22],
                    au_key
  end

  context 'disable_windows_update_access =>', {:testrail => ['70220', '70221']} do
    it_behaves_like 'boolean values',
                    :disable_windows_update_access,
                    'DisableWindowsUpdateAccess'
  end

  context 'elevate_non_admins =>', {:testrail => ['70223', '70224']} do
    it_behaves_like 'boolean values',
                    :elevate_non_admins,
                    'ElevateNonAdmins'

  end

  context 'no_auto_reboot_with_logged_on_users =>', {:testrail => ['70226', '70227']} do
    it_behaves_like 'boolean values',
                    :no_auto_reboot_with_logged_on_users,
                    'NoAutoRebootWithLoggedOnUsers',
                    au_key
  end

  context 'no_auto_update =>', {:testrail => ['70229', '70230']} do
    it_behaves_like 'boolean values',
                    :no_auto_update,
                    'NoAutoUpdate',
                    au_key
  end

  context 'reboot_relaunch_timeout_minutes =>', {:testrail => ['70232', '70233', '70234']} do
    it_behaves_like 'enabled range',
                    :reboot_relaunch_timeout_minutes,
                    'RebootRelaunchTimeout',
                    [1, 1440],
                    au_key
  end

  context 'reboot_warning_timeout_minutes =>', {:testrail => ['70239', '70240', '70241']} do
    it_behaves_like 'enabled range',
                    :reboot_warning_timeout_minutes,
                    'RebootWarningTimeout',
                    [1, 30],
                    au_key
  end

  context 'reschedule_wait_time_minutes =>', {:testrail => ['70246', '70247', '70248']} do
    it_behaves_like 'enabled range',
                    :reschedule_wait_time_minutes,
                    'RescheduleWaitTime',
                    [1, 60],
                    au_key
  end

  context 'scheduled_install_day =>', {:testrail => ['70253', '70254', '70255', '70256']} do
    {'Everyday' => 0, 'Tuesday' => 3, 0 => 0, 3 => 3}.each do |day, expected_value|
      describe "#{day}" do
        it {
          create_apply_manifest :auto_update_option => 'Scheduled',
                                :scheduled_install_day => day,
                                :scheduled_install_hour => 18 }
        it_behaves_like 'registry_value', 'ScheduledInstallDay', au_key do
          let(:reg_data) { expected_value }
        end
        it_behaves_like 'registry_value', 'AUOptions', au_key do
          let(:reg_data) { 4 }
        end
      end
    end
  end

  context 'scheduled_install_hour =>', {:testrail => ['70263', '70264']} do
    [0, 23].each do |hour|
      describe "#{hour}" do
        it {
          create_apply_manifest :auto_update_option => 'Scheduled',
                                :scheduled_install_day => 'Tuesday',
                                :scheduled_install_hour => hour }
        it_behaves_like 'registry_value', 'ScheduledInstallTime', au_key do
          let(:reg_data) { hour }
        end
        it_behaves_like 'registry_value', 'AUOptions', au_key do
          let(:reg_data) { 4 }
        end
      end
    end
  end

  context 'target_group =>', {:testrail => ['70268']} do
    describe 'testTargetGroup' do
      it {
        create_apply_manifest :target_group => 'testTargetGroup'
      }
      it_behaves_like 'registry_value', 'TargetGroup' do
        let(:reg_data) { 'testTargetGroup' }
        let(:reg_type) { :type_string }
      end
      it_behaves_like 'registry_value', 'TargetGroupEnabled' do
        let(:reg_data) { 1 }
        let(:reg_type) { :type_dword_converted }
      end
    end
    describe 'false', {:testrail => ['89606']} do
      it {
        create_apply_manifest :target_group => false
      }
      it_behaves_like 'registry_value', 'TargetGroupEnabled' do
        let(:reg_data) { 0 }
        let(:reg_type) { :type_dword_converted }
      end
    end
  end
end
