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
  Pre Server 2012 this would be located under 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate'
  For Server 2012+ 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate'
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
  au_option              => 4,
  scheduled_install_day  => 2, #Patch Tuesdays 
  scheduled_install_time => 2, # 4AM
}
```

####Ensure we are reporting the status back to our WSUS server
```
class { 'wsus_client':
  server_url               => 'http://myserver:8530',
  wu_status_server_enabled => true,
}
```

####Enable detection_frequency with value
This will set the enabled flag for the DetectionFrequency to true and set DetectionFrequency to hourly
```
 class {'wsus_client':
   server_url          => 'http://myserver:8530',
   detection_frequency => 1
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

#### wsus_client class

* `server_url`: The URL which your WSUS server can be reached.  For example: http://wsus.domain.net:8530
* `wu_status_server_enabled`: Whether to also set the status server as well.
* `accept_trusted_publisher_certs`: Whether to accept trusted publisher certs when checking for updates.
* `au_option`: The auto update option you would like to use, please see (url) for descriptions.  Valid values are 2-5
* `auto_install_minor_updates`: Whether to auto install minor updates without user interaction
* `detection_frequency_hours`: The frequency to check for updates. 
* `disable_windows_update_access`: This option will disable windows update from non-admin users.
* `elevate_non_admins`: Whether to elevate non-admins when attempting to update.
* `no_auto_reboot_with_logged_on_users`: Disables reboot when a user is logged in to the system.
* `no_auto_update`: Disable Auto Update
* `reboot_relaunch_timeout_minutes`: How long to wait before reboot will be attempted again. Valid values are 1-440 min.
* `reboot_warning_timeout_minutes`: How long to give the user to respond before rebooting the system.
* `reschedule_wait_time_minutes`: How long to reschedule between attempts to update.
* `scheduled_install_day`: Day of the week to install updates on. ####Todo need to determine what is valid, code says 0,7 but not possible 
* `scheduled_install_hour`: Hour of the day to install updates, valid values are 0-23
* `target_group`: The target group that the machine belongs to, note this setting is only respected when allowed from WSUS Server
* `purge_values`: Whether to purge the registry values we are not managing under WindowsUpdate parent key.

## Limitations

Windows 2003+

## Development

This is a proprietary module only available to Puppet Enterprise users. As such, we have no formal way for users to contribute toward development. 
However, we know our users are a charming collection of brilliant people, so if you have a bug you've fixed or a contribution to this module, 
please generate a diff and throw it into a ticket to support---they'll ensure that we get it.
