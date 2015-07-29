# wsus_client

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with wsus_client](#setup)
  * [What wsus affects](#what-wsus_client-affects)
  * [Beginning with wsus](#beginning-with-wsus_client)
4. [Usage - Configuration options and additional functionality](#usage)
  * [Scheduled Auto Update](#scheduled-auto-update)
  * [Enabling Status Server](#enabling-status-server)
  * [Enabled parameters](#enabled-parameters)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations](#limitations)

## Overview

This tool is used to configure WSUS (Windows Server Update Service) settings on client nodes to point to a particular host and settings pertinent to scheduling and installing patches passed down from your WSUS server.

## Module Description

This module can be used to configure agent nodes to point to a WSUS Server for patches instead of Windows Update servers. But also can be used to schedule updates and configure if the user should be able to manage them or even if auto update is enabled.

## Setup

Install this module with the following command:

~~~
$ puppet module install [--modulepath <path>] puppetlabs/wsus_client
~~~

The above command also includes the optional argument to specify your Puppet master's `modulepath` as the location to install the module.


### What wsus_client affects

The module updates registry keys located in `HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate`

### Beginning with wsus_client

#### Set the WSUS server url to connect to

~~~puppet
class { 'wsus_client':
  server_url => 'http://myserver:8530',
}
~~~

## Usage



### Scheduled Auto Update

The following will schedule for every Tuesday at 2AM against WSUS Server 'myserver' using port 8530 over http

~~~puppet
class { 'wsus_client':
  server_url             => 'http://myserver:8530',
  auto_update_option     => "Scheduled",
  scheduled_install_day  => "Tuesday",
  scheduled_install_hour => 2,
}
~~~

### Enabling Status Server

The following will set registry keys for both `WUServer` and `WUStatusServer` to 'http://myserver:8530' as well as `UseWUServer` bit to `1` or `true`

~~~puppet
class { 'wsus_client':
  server_url           => 'http://myserver:8530',
  enable_status_server => true,
}
~~~

### Enabled parameters

There are several parameters which will affect up to two different registry keys, these parameters are known as enabled parameters.  Affectively they require both a value and a registry key switch set to '1' (true) in order to take affect.  For example `reschedule_wait_time_minutes` takes a integer value from `1` to `60` as well as `true` or `false`.  If the value is set to a valid value  other than 'false' it will set the 'RescheduleWaitTimeEnabled' flag to `1` (true) in the registry.  If set to `false` it will set it to '0' which disables this feature and will not be used with WSUS configuration.
The parameters that follow this pattern are:
* `detection_frequency_hours`
* `reboot_relaunch_timeout_minutes`
* `reboot_warning_timeout_minutes`
* `reschedule_wait_time_minutes`
* `target_group`

#### Enabled parameter example

This will set the enabled flag for the registry value 'DetectionFrequencyEnabled' to 1 (true) and the 'DetectionFrequency' to 5 which is every 5 hours

~~~puppet
 class { 'wsus_client':
   server_url                => 'http://myserver:8530',
   detection_frequency_hours => 5
 }
~~~

#### Disable parameter example

This will expressly disable the detection frequency by setting the 'DetectionFrequencyEnabled' bit to 0 (false) but will not affect any value for 'DetectionFrequency'

~~~puppet
class { 'wsus_client':
  server_url          => 'http://myserver:8530',
  detection_frequency => false
}
~~~

## Reference

### Class: wsus_client

The main class of this module, responsible for all its functionality.

#### Parameters

All the parameters below are optional unless otherwise noted

#### `server_url`

The URL which your WSUS server can be reached. For example: 'http://wsus.domain.net:8530' Valid options: URL including protocol and port.  When set it will affect two registry keys 'UseUWServer' and 'WUServer' where 'WUServer' is the url provided and 'UseWUServer' is a bit operator set to true or false accordingly.
It is recommended in most cases to use 'http' over 'https' as it will default to using 'https' when required and assumes that the port is incremented by 1 from the one provided in the configuration.  For example if providing the aforementioned url it would then use 'https://wsus.domain.net:8531' for authentication and 'http' to pull down the bits.  This is purely for performance reasons to avoid the overhead of 'ssl' for binary downloads.

#### `enable_status_server`

Whether to also set the status server as well. This sets the value for status_server to the value specified in server_url. Valid options: 'true', 'false' and 'undef'. Default: 'undef'

When setting to 'true' it will registry key 'WUStatusServer' with the value from `server_url`. However when set to 'false' it with remove the registry key 'WUStatusServer'

**Note.** We use the `server_url` due to the fact that Microsoft documentation states 'This policy is paired with WUServer, and both keys must be set to the same value to be valid.'

##### `accept_trusted_publisher_certs`

Whether to accept trusted publisher certs when checking for updates. Valid
options: 'true', 'false' and 'undef'. Default: 'undef'

##### `auto_update_option`

The auto update option you would like to use, please see (url) for descriptions. Valid values are 2-5, 'NotifyOnly', 'AutoNotify', 'Scheduled', 'AutoInstall'. Default: 'undef'

##### `auto_install_minor_updates`

Whether to auto install minor updates without user interaction. Valid options: 'true', 'false' and 'undef'. Default: 'undef'

##### `detection_frequency_hours`

The frequency to check for updates. Valid values are 1 through 22

##### `disable_windows_update_access`

This option will disable windows update from non-admin users. Valid options: 'true', 'false' and 'undef'. Default: 'undef'

##### `elevate_non_admins`

Whether to elevate non-admins when attempting to update. Valid options: 'true', 'false' and 'undef'. Default: 'undef'

##### `no_auto_reboot_with_logged_on_users`

Disables reboot when a user is logged in to the system. Valid options: 'true', 'false' and 'undef'. Default: 'undef'

##### `no_auto_update`

Disable Auto Update. Valid options: 'true', 'false' and 'undef'. Default: 'undef'

##### `reboot_relaunch_timeout_minutes`

How long to wait before reboot will be attempted again. Valid values are 1 through 1440. Default: 'undef'

##### `reboot_warning_timeout_minutes`

How long to give the user to respond before rebooting the system. Valid values are 1 through 30. Default: 'undef'

##### `reschedule_wait_time_minutes`

How long to reschedule between attempts to update. Valid values are 1 through 60. Default: 'undef'

##### `scheduled_install_day`

Day of the week to install updates on. Valid values are 'Everyday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', also takes integer values 0-7. Default: 'undef'

##### `scheduled_install_hour`

Hour of the day to install updates. Valid values are 0 through 23. Default: 'undef'

##### `target_group`

The target group that the machine belongs to, note this setting is only respected when allowed from WSUS Server. Valid values are String. Default: 'undef'

#### `purge_values`

Whether to purge the registry values we are not managing under WindowsUpdate parent key. Valid options: 'true' and 'false'. Default: 'false'

## Links

[Microsoft - Configuring Automatic Updates using the Registry Editor](https://technet.microsoft.com/en-us/library/dd939844(v=ws.10).aspx)

## Limitations

Windows 2003+
