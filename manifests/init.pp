class wsus_client (
  $server_url                          = undef,
  $enable_status_server                = false,
  $accept_trusted_publisher_certs      = undef,
  $auto_update_option                  = undef, #2..5 valid values
  $auto_install_minor_updates          = undef,
  $detection_frequency                 = undef,
  $disable_windows_update_access       = undef,
  $elevate_non_admins                  = undef,
  $no_auto_reboot_with_logged_on_users = undef,
  $no_auto_update                      = undef,
  $reboot_relaunch_timeout             = undef,
  $reboot_warning_timeout              = undef,
  $reschedule_wait_time                = undef,
  $scheduled_install_day               = undef,
  $scheduled_install_time              = undef,
  $target_group                        = undef,
  $purge_values                        = false,
){

  $_basekey = $::operatingsystemrelease ? {
    /2012/  => 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate',
    default => 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate'
  }

  $_au_base = $::operatingsystemrelease ? {
    /2012/  => "${_basekey}\\Auto Update",
    default => "${_basekey}\\AU"
  }

  validate_bool($purge_values)

  registry_key{ $_basekey:
    purge_values => $purge_values
  }

  registry_key{ $_au_base:
    purge_values => $purge_values
  }

  service{ 'wuauserv':
    ensure  => running,
    enable  => true,
  }

  Registry_value{ require => Registry_key[$_basekey], notify => Service['wuauserv'] }


  if ($server_url == undef or $server_url == false) and $enable_status_server {
    fail('server_url is required when specifying enable_status_server => true')
  }

  if $server_url  != undef {
    registry_value{ "${_au_base}\\UseWUServer":
      type => 'dword',
      data => bool2num($server_url != false),
    }
    if $server_url {
      validate_re($server_url, '^http(|s):\/\/', "server_url is required to be either http or https, ${server_url}")
      registry_value{ "${_basekey}\\WUServer":
        type => string,
        data => $server_url,
      }
      if $enable_status_server {
        validate_bool($enable_status_server)
        registry_value{ "${_basekey}\\WUStatusServer":
          type => string,
          data => $server_url,
        }
      }
    }
  }

  if $auto_update_option {
    $_parsed_auto_update_option = parse_auto_update_option($auto_update_option)
    if $_parsed_auto_update_option == 4 and !($scheduled_install_day and $scheduled_install_time) {
      fail("scheduled_install_day and scheduled_install_time required when specifying auto_update_option => '${auto_update_option}'")
    }
    registry_value{ "${_au_base}\\AUOptions":
      type => dword,
      data => $_parsed_auto_update_option,
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
    data           => $detection_frequency,
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
    data           => $reboot_relaunch_timeout,
    validate_range => [1,440],
  }

  wsus_client::setting{ "${_au_base}\\RebootWarningTimeout":
    data           => $reboot_warning_timeout,
    validate_range => [1,30]
  }

  wsus_client::setting{ "${_au_base}\\RescheduleWaitTime":
    data           => $reschedule_wait_time,
    validate_range => [1,60],
  }

  wsus_client::setting{ "${_au_base}\\ScheduledInstallDay":
    data           => $scheduled_install_day,
    validate_range => [0,7],
    has_enabled    => false,
  }

  wsus_client::setting{ "${_au_base}\\ScheduledInstallTime":
    data           => $scheduled_install_time,
    validate_range => [0,23],
    has_enabled    => false,
  }

  wsus_client::setting{ "${_basekey}\\TargetGroup":
    type        => 'string',
    data        => $target_group,
  }
}
