class wsus_client (
  $server_url                          = undef,
  $enable_status_server                = undef,
  $accept_trusted_publisher_certs      = undef,
  $auto_update_option                  = undef, #2..5 valid values
  $auto_install_minor_updates          = undef,
  $detection_frequency_hours           = undef,
  $disable_windows_update_access       = undef,
  $elevate_non_admins                  = undef,
  $no_auto_reboot_with_logged_on_users = undef,
  $no_auto_update                      = undef,
  $reboot_relaunch_timeout_minutes     = undef,
  $reboot_warning_timeout_minutes      = undef,
  $reschedule_wait_time_minutes        = undef,
  $scheduled_install_day               = undef,
  $scheduled_install_hour              = undef,
  $target_group                        = undef,
  $purge_values                        = false,
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
    ensure => running,
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
}
