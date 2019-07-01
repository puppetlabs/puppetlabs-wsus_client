# @summary
#   This module manages operating system updates.
#
# This module configures Puppet agents to schedule update downloads and installations from a WSUS server,
# manage user access to update settings, and configure automatic updates.
#
# @example
#    class { 'wsus_client': }
#
# @param server_url
#   Sets the URL at which your WSUS server can be reached. Valid options: fully qualified URL starting with 'http' or 'https', including protocol and port; 'false'; or undef. Default: undef.
#   When set to a URL, Puppet sets the WUServer registry key to this parameter's value and the UseWUServer registry key to '1' (true).
#   If this parameter is set to 'false', Puppet sets UseWUServer to false, disabling WSUS updates on the client. If undefined, Puppet does not manage WUServer or UseWUServer.
#   Even if HTTPS is required for authentication, you can use 'http' URLs instead of 'https'. WSUS automatically switches to an HTTPS connection when required and increments the provided port by 1. For example, if the server_url is 'http://myserver:8530' and the WSUS server requires HTTPS access, the client automatically uses 'https://myserver:8531' to authenticate, then downloads the updates without encryption via the server_url. This performs better than using SSL to encrypt binary downloads.
#   Note: The server_url parameter is central to using wsus_client to manage updates from a WSUS server. While not strictly required to use the class, note that you must manage the WUServer and UseWUServer registry keys yourself if you do not set server_url and enable_status_server.
#
# @param enable_status_server
#   Determines whether Puppet also sets the WUStatusServer registry key, which sets the client status reporting destination. Valid options: 'true', 'false', and undef. Default: undef.
#   If this parameter is set to true, Puppet sets the value for the WUStatusServer registry key to the server_url parameter's value. Therefore, when setting this parameter to true, you must also set the server_url parameter to a valid URL or your Puppet run will fail with an error.
#   If enable_status_server is set to 'false', Puppet removes the WUStatusServer registry key.
#   Note: Windows requires the same value for WUStatusServer and WUServer, so wsus_client does not provide an option to set a different status server URL.
#
# @param accept_trusted_publisher_certs
#   Determines whether to accept trusted non-Microsoft publisher certificates when checking for updates. Valid options: 'true', 'false', and undef.
#   Default: undef.
#   If 'true', the WSUS server distributes signed non-Microsoft updates.
#   If 'false', the WSUS server only distributes Microsoft updates.
#
# @param auto_update_option
#   Sets the automatic update option you would like to use. Valid values: 'NotifyOnly', 'AutoNotify', 'Scheduled', and 'AutoInstall'.
#   You can also refer to these four values using integers 2 through 5, respectively.
#   Default: undef.
#
#   See the AUOptions key values on the Microsoft TechNet documentation for detailed descriptions of these options. In summary:
#
#   * 'NotifyOnly': Notifies users before downloading updates.
#   * 'AutoNotify': Automatically downloads updates and notifies users.
#   * 'Scheduled': Automatically downloads updates and schedules automatic installation.
#
#   If set to this value, scheduled_install_day and scheduled_install_hour are required.
#   This parameter must be set to this value to use reschedule_wait_time_minutes.
#   'AutoInstall': Requires fully automatic updates that users can configure if allowed.
#
# @param auto_install_minor_updates
#   Determines whether to silently install minor updates automatically. Valid options: 'true', 'false', and undef.
#   If 'true', Windows installs minor updates without user interaction.
#   If 'false', Windows treats them as any other update, which depends on other settings such as auto_update_option.
#
# @param detection_frequency_hours
#   Sets an interval in hours for clients to check for updates. Valid values: integers 1 through 22.
#   Default: undef.
#   If this enabled parameter has a valid value, Puppet sets the DetectionFrequency registry key to its value and the DetectionFrequencyEnabled Boolean registry key to 'true'.
#   Otherwise, Puppet sets DetectionFrequencyEnabled to 'false' and Windows ignores the value of DetectionFrequency, falling back to the Windows default value of 22 hours.
#
# @param disable_windows_update_access
#   Determines whether non-administrators can access Windows Update. Valid options: 'true' (disable access), 'false' (enable access), and undef.
#   Default: undef.
#
# @param elevate_non_admins
#   Determines which security groups can approve or refuse updates. Valid options: 'true', 'false', and undef.
#   Default: undef.
#   If 'true', members of the Users group can approve or refuse updates.
#   If 'false', only members of the Administrators group can approve or refuse updates.
#
# @param no_auto_reboot_with_logged_on_users
#   Determines whether to automatically reboot while a user is logged in to the client. Valid options: 'true', 'false', and undef. Default: undef.
#   If 'true', Windows will not restart the client after installing updates, even if a reboot is required to finish installing the update. If 'false', Windows notifies the user that the client will restart 15 minutes after installing an update that requires a reboot.
#
# @param no_auto_update
#   Disables automatic updates. Valid options: 'true', 'false' (automatic updates enabled), and undef. Default: undef.
#   Windows disables automatic updates when this parameter is set to 'true' and enables them if it's set to 'false'.
#
# @param reboot_relaunch_timeout_minutes
#  Sets a delay in minutes to wait before attempting to reboot after installing an update that requires one. Valid values: integers 1 through 1440. Default: undef.
#  If this enabled parameter has a valid value, Puppet sets the RebootRelaunchTimeout registry key to its value and the RebootRelaunchTimeoutEnabled Boolean registry key to 'true'. Otherwise, Puppet sets RebootRelaunchTimeoutEnabled to 'false' and Windows ignores the value of RebootRelaunchTimeout, falling back to the Windows default value of 10 minutes.
#
# @param reboot_warning_timeout_minutes
#   Sets how many minutes users can wait before responding to a prompt to reboot the client after installing an update that requires a reboot. Valid values: integers 1 through 30. Default: undef.
#   If this enabled parameter has a valid value, Puppet sets the RebootWarningTimeout registry key to its value and the RebootWarningTimeoutEnabled Boolean registry key to 'true'. Otherwise, Puppet sets RebootWarningTimeoutEnabled to 'false' and Windows ignores the value of RebootWarningTimeout, falling back to the Windows default value of 5 minutes.
#
# @param reschedule_wait_time_minutes
#   Sets how many minutes the client's automatic update service waits at startup before applying updates from a missed scheduled update. Valid values: integers 1 through 60. Default: undef.
#   This enabled parameter is used only when automatic updates are enabled and auto_update_option is set to 'Scheduled' or '4'. If this parameter is set to a valid value, Puppet sets the RescheduleWaitTime registry key to that value and the RescheduleWaitTimeEnabled Boolean registry key to 'true'. Otherwise, Puppet sets RescheduleWaitTimeEnabled to 'false' and Windows ignores the value of RescheduleWaitTime, falling back to the Windows default behavior of re-attempting installation at the next scheduled update time.
#
# @param scheduled_install_day
#   Schedules a day of the week to automatically install updates. Valid values: 'Everyday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', and 'Saturday'. You can also refer to these eight values using the integers 0 through 7, respectively. Default: undef.
#   This parameter depends on a valid scheduled_install_hour value and is required when auto_update_option is set to 'Scheduled' or '4'.
#
# @param scheduled_install_hour
#   Schedules an hour of the day to automatically install updates. Valid values: an integer from 0 through 23. Default: undef.
#   This parameter depends on a valid scheduled_install_day value and is required when auto_update_option is set to 'Scheduled' or '4'.
#
# @param always_auto_reboot_at_scheduled_time
#   Determines whether to automatically reboot. Valid options: 'true', 'false', and undef. Default: undef.
#
# @param always_auto_reboot_at_scheduled_time_minutes
#    Sets the timer to warning a signed-in user that a restart is going to occur. Valid values: integers 15 through 180. Default: undef.
#    When the timer runs out, the restart will proceed even if the PC has signed-in users.
#
# @param purge_values
#   Determines whether Puppet purges values of unmanaged registry keys under the WindowsUpdate parent key. Valid options: Boolean. Default: 'false'.
#
# @param target_group
#   Sets the client's target group. Valid values: a string. Default: undef.
#   This enabled parameter is only respected when the WSUS server allows clients to modify this setting via the TargetGroup and TargetGroupEnabled registry keys.
#
class wsus_client (
  $server_url                                   = undef,
  $enable_status_server                         = undef,
  $accept_trusted_publisher_certs               = undef,
  $auto_update_option                           = undef, #2..5 valid values
  $auto_install_minor_updates                   = undef,
  $detection_frequency_hours                    = undef,
  $disable_windows_update_access                = undef,
  $elevate_non_admins                           = undef,
  $no_auto_reboot_with_logged_on_users          = undef,
  $no_auto_update                               = undef,
  $reboot_relaunch_timeout_minutes              = undef,
  $reboot_warning_timeout_minutes               = undef,
  $reschedule_wait_time_minutes                 = undef,
  $scheduled_install_day                        = undef,
  $scheduled_install_hour                       = undef,
  $always_auto_reboot_at_scheduled_time         = undef,
  $always_auto_reboot_at_scheduled_time_minutes = undef,
  $target_group                                 = undef,
  $purge_values                                 = false,
){

  $_basekey = $::operatingsystemrelease ? {
    default => 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate'
  }

  $_au_base = $::operatingsystemrelease ? {
    default => "${_basekey}\\AU"
  }

  validate_bool($purge_values)

  registry_key{ $_basekey:
    ensure       => present,
    purge_values => $purge_values
  }

  registry_key{ $_au_base:
    ensure       => present,
    purge_values => $purge_values
  }

  service{ 'wuauserv':
    enable => true,
  }

  Registry_value{ require => Registry_key[$_basekey], notify => Service['wuauserv'] }


  if ($server_url == undef or $server_url == false) and $enable_status_server {
    fail('server_url is required when specifying enable_status_server => true')
  }

  if $server_url  != undef {
    wsus_client::setting{ "${_au_base}\\UseWUServer":
      data        => bool2num($server_url != false),
      has_enabled => false,
    }
    if $server_url {
      validate_re($server_url, '^http(|s):\/\/', "server_url is required to be either http or https, ${server_url}")
      wsus_client::setting{ "${_basekey}\\WUServer":
        type        => 'string',
        data        => $server_url,
        has_enabled => false,
      }
      if $enable_status_server != undef {
        validate_bool($enable_status_server)
        $_ensure_status_server = $enable_status_server ? {
          true => 'present',
          false => 'absent',
        }
        wsus_client::setting{ "${_basekey}\\WUStatusServer":
          ensure      => $_ensure_status_server,
          type        => 'string',
          data        => $server_url,
          has_enabled => false,
        }
      }
    }
  }


  if $auto_update_option {
    $_parsed_auto_update_option = parse_auto_update_option($auto_update_option)
    if $_parsed_auto_update_option == 4 and !($scheduled_install_day and $scheduled_install_hour) {
      fail("scheduled_install_day and scheduled_install_hour required when specifying auto_update_option => '${auto_update_option}'")
    }
    wsus_client::setting{ "${_au_base}\\AUOptions":
      data        => $_parsed_auto_update_option,
      has_enabled => false,
    }
  }

  wsus_client::setting { "${_basekey}\\AcceptTrustedPublisherCerts":
    data          => $accept_trusted_publisher_certs,
    has_enabled   =>  false,
    validate_bool => true,
  }

  wsus_client::setting { "${_au_base}\\AutoInstallMinorUpdates":
    data          => $auto_install_minor_updates,
    has_enabled   => false,
    validate_bool => true,
  }

  wsus_client::setting{ "${_au_base}\\DetectionFrequency":
    data           => $detection_frequency_hours,
    validate_range => [1,22],
  }

  wsus_client::setting{ "${_basekey}\\DisableWindowsUpdateAccess":
    data          => $disable_windows_update_access,
    has_enabled   => false,
    validate_bool => true,
  }

  wsus_client::setting{ "${_basekey}\\ElevateNonAdmins":
    data          => $elevate_non_admins,
    has_enabled   => false,
    validate_bool => true,
  }

  wsus_client::setting{ "${_au_base}\\NoAutoRebootWithLoggedOnUsers":
    data          => $no_auto_reboot_with_logged_on_users,
    has_enabled   => false,
    validate_bool => true,
  }

  wsus_client::setting{ "${_au_base}\\NoAutoUpdate":
    data          => $no_auto_update,
    has_enabled   => false,
    validate_bool => true,
  }

  wsus_client::setting{ "${_au_base}\\RebootRelaunchTimeout":
    data           => $reboot_relaunch_timeout_minutes,
    validate_range => [1,1440],
  }

  wsus_client::setting{ "${_au_base}\\RebootWarningTimeout":
    data           => $reboot_warning_timeout_minutes,
    validate_range => [1,30]
  }

  wsus_client::setting{ "${_au_base}\\RescheduleWaitTime":
    data           => $reschedule_wait_time_minutes,
    validate_range => [1,60],
  }

  $_scheduled_install_day =  $scheduled_install_day ? {
    true     => true,
    false    => false,
    /\w+|\d/ => parse_scheduled_install_day($scheduled_install_day),
    default  => $scheduled_install_day
  }

  wsus_client::setting{ "${_au_base}\\ScheduledInstallDay":
    data           => $_scheduled_install_day,
    validate_range => [0,7],
    has_enabled    => false,
  }

  wsus_client::setting{ "${_au_base}\\ScheduledInstallTime":
    data           => $scheduled_install_hour,
    validate_range => [0,23],
    has_enabled    => false,
  }

  wsus_client::setting{ "${_basekey}\\TargetGroup":
    type => 'string',
    data => $target_group,
  }

  wsus_client::setting{ "${_au_base}\\AlwaysAutoRebootAtScheduledTime":
    data          => $always_auto_reboot_at_scheduled_time,
    has_enabled   => false,
    validate_bool => true,
  }
  wsus_client::setting{ "${_au_base}\\AlwaysAutoRebootAtScheduledTimeMinutes":
    data           => $always_auto_reboot_at_scheduled_time_minutes,
    validate_range => [15,180],
    has_enabled    => false,
  }
}
