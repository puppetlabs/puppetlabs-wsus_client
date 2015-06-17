# wsus_client

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with wsus_client](#setup)
    * [What wsus affects](#what-wsus_client-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with wsus](#beginning-with-wsus_client)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations](#limitations)
7. [Development](#development)

## Overview

This tool is used to configure WSUS(Windows Server Update Service) settings on client nodes to point to a particular host
 and settings pertinent to scheduling and installing patches passed down from your WSUS server.

## Module Description

This module can be used to configure agent nodes to point to a WSUS Server for patches instead of Windows Update servers.
 But also can be used to schedule updates and configure if the user should be able to manage them or even if auto update is enabled.

## Setup

### What wsus_client affects

* Manages the registry keys that pertain to WSUS configuration.
  This would be located under 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate'
* This is a great place to stick any warnings.
* Can be in list or paragraph form.

### Beginning with wsus_client

####Set the WSUS server url to connect to
 ```
 class { 'wsus_client':
   server_url => 'http://myserver:8530',
 }
 ```

## Usage

####Set the auto update to a scheduled date and time and disable user access
```
class { 'wsus_client':
  server_url             => 'http://myserver:8530',
  auto_update_option     => "Scheduled",
  scheduled_install_day  => 2, #Patch Tuesdays 
  scheduled_install_time => 2, # 4AM
}
```

####Ensure we are reporting the status back to our WSUS server
```
class { 'wsus_client':
  server_url           => 'http://myserver:8530',
  enable_status_server => true,
}
```

####Enable detection_frequency with value
This will set the enabled flag for the DetectionFrequency to true and set DetectionFrequency to hourly
```
 class {'wsus_client':
   server_url                => 'http://myserver:8530',
   detection_frequency_hours => 1
 }
```

####Disable detection_frequency
This will expressly disable the detection frequency by setting the DetectionFrequencyEnabled bit to false
```
class {'wsus_client':
  server_url          => 'http://myserver:8530',
  detection_frequency => false
}
```

## Reference

### Classes

#### `wsus_client`

* `server_url`: *Optional.* The URL which your WSUS server can be reached.  For example: http://wsus.domain.net:8530 Valid options: URL including protocol
* `enable_status_server`: *Optional.* Whether to also set the status server as well. Valid options: 'true', 'false' and 'undef'. Default: 'undef'
* `accept_trusted_publisher_certs`: *Optional.* Whether to accept trusted publisher certs when checking for updates. Valid options: 'true', 'false' and 'undef'. Default: 'undef'
* `auto_update_option`: *Optional.* The auto update option you would like to use, please see (url) for descriptions.  Valid values are 2-5, 'NotifyOnly', 'AutoNotify', 'Scheduled', 'AutoInstall'. Default: 'undef'
* `auto_install_minor_updates`: *Optional.* Whether to auto install minor updates without user interaction. Valid options: 'true', 'false' and 'undef'. Default: 'undef'
* `detection_frequency_hours`: *Optional.* The frequency to check for updates. Valid values are 1 through 22 
* `disable_windows_update_access`: *Optional.* This option will disable windows update from non-admin users. Valid options: 'true', 'false' and 'undef'. Default: 'undef'
* `elevate_non_admins`: *Optional.* Whether to elevate non-admins when attempting to update. Valid options: 'true', 'false' and 'undef'. Default: 'undef'
* `no_auto_reboot_with_logged_on_users`: *Optional.* Disables reboot when a user is logged in to the system. Valid options: 'true', 'false' and 'undef'. Default: 'undef'
* `no_auto_update`: *Optional.* Disable Auto Update. Valid options: 'true', 'false' and 'undef'. Default: 'undef'
* `reboot_relaunch_timeout_minutes`: *Optional.* How long to wait before reboot will be attempted again. Valid values are 1 through 440. Default: 'undef'
* `reboot_warning_timeout_minutes`: *Optional.* How long to give the user to respond before rebooting the system. Valid values are 1 through 30. Default: 'undef'
* `reschedule_wait_time_minutes`: *Optional.* How long to reschedule between attempts to update. Valid values are 1 through 60. Default: 'undef'
* `scheduled_install_day`: *Optional.* Day of the week to install updates on. Valid values are Everyday, Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday. Default: 'undef'
* `scheduled_install_hour`: *Optional.* Hour of the day to install updates. Valid values are 0 through 23. Default: 'undef'
* `target_group`: *Optional.* The target group that the machine belongs to, note this setting is only respected when allowed from WSUS Server. Valid values are String. Default: 'undef'
* `purge_values`: *Optional.* Whether to purge the registry values we are not managing under WindowsUpdate parent key. Valid options: 'true' and 'false'. Default: 'false'

## Limitations

Windows 2003+

## Development

