# wsus_client

[`auto_update_option`]: #auto_update_option

[`detection_frequency_hours`]: #detection_frequency_hours

[`enable_status_server`]: #enable_status_server
[enabled parameter]: #enabled-parameters

[`purge_values`]: #purge_values

[TechNet]: https://technet.microsoft.com/en-us/library/dd939844.aspx
[WSUS server]: https://technet.microsoft.com/en-us/library/hh852338.aspx

[`reboot_relaunch_timeout_minutes`]: #reboot_relaunch_timeout_minutes
[`reboot_warning_timeout_minutes`]: #reboot_warning_timeout_minutes

[`reschedule_wait_time_minutes`]: #reschedule_wait_time_minutes

[`scheduled_install_day`]: #scheduled_install_day
[`scheduled_install_hour`]: #scheduled_install_hour
[`server_url`]: #server_url

[`target_group`]: #target_group

#### Table of Contents

1. [Module Description - What is the wsus_client module, and what does it do?](#module-description)
  * [What wsus_client affects](#what-wsus_client-affects)
2. [Setup - The basics of getting started with wsus_client](#setup)
  * [Beginning with wsus_client](#beginning-with-wsus_client)
3. [Usage - Configuration options and additional functionality](#usage)
  * [Schedule updates](#schedule-updates)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations](#limitations)
6. [Developments](#developments)

## Module Description

The Windows Server Update Service (WSUS) lets Windows administrators manage operating system updates using their own servers instead of Microsoft's Windows Update servers.

This module configures Puppet agents to schedule update downloads and installations from a WSUS server, manage user access to update settings, and configure automatic updates.

### What wsus_client affects

This module modifies registry keys in `HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate`. For details about how registry key-driven WSUS configuration works, see the [Microsoft TechNet documentation][TechNet].

**Note**: Because this module modifies registry keys on clients, it is incompatible with Group Policy Objects that manage the same WSUS settings. **Do not use wsus_client to configure WSUS access or automatic updates if you use Group Policies to configure such options on clients**, as doing so can lead to unexpected behavior. Instead, consult Microsoft's documentation on [configuring automatic updates using Group Policy](https://technet.microsoft.com/en-us/library/dd939933.aspx).

## Setup

To use wsus_client, you must have a configured and running WSUS server, and your clients must run Windows Server 2003 or newer. For more information about deploying WSUS, see Microsoft's [WSUS Deployment Guide](https://technet.microsoft.com/en-us/library/dd939906.aspx).

To install this module on your Puppet master, run this command:

~~~
$ puppet module install [--modulepath <PATH>] puppetlabs/wsus_client
~~~

If necessary, use the optional `--modulepath` argument to specify your Puppet master's `modulepath`.

### Beginning with wsus_client

To have the client use a WSUS server and set the server's location, declare the `wsus_client` class with the WSUS server's url in the [`server_url`][] parameter.

For example, to point a node at a WSUS server located at `http://myserver` on port 8530, declare this class:

~~~ puppet
class { 'wsus_client':
  server_url => 'http://myserver:8530',
}
~~~

## Usage

### Schedule updates

To schedule when to retrieve and automatically install updates from a WSUS server, declare the `wsus_client` class with a WSUS [`server_url`][] as well as the [`auto_update_option`][], [`scheduled_install_day`][], and [`scheduled_install_hour`][] parameters.

For example, to schedule weekly updates at 2 a.m. on Tuesdays using a WSUS server at `http://myserver:8530`, declare this class:

~~~ puppet
class { 'wsus_client':
  server_url             => 'http://myserver:8530',
  auto_update_option     => "Scheduled",
  scheduled_install_day  => "Tuesday",
  scheduled_install_hour => 2,
}
~~~

Clients can report update events to a WSUS status server as defined by the `WUStatusServer` registry key, which must have the same value as the `WUServer` policy to be valid for automatic updates. For details, see the [Microsoft TechNet documentation][TechNet].

To report the client's status to the WSUS server, use the [`enable_status_server`][] parameter. For example, to configure a client to use `http://myserver:8530` for both updates and status reporting, declare this class:

~~~ puppet
class { 'wsus_client':
  server_url           => 'http://myserver:8530',
  enable_status_server => true,
}
~~~

## Reference

### Class: `wsus_client`

The module's main class is responsible for all its functionality.

#### Parameters

All parameters are optional unless otherwise noted.

#### `accept_trusted_publisher_certs`

Determines whether to accept trusted non-Microsoft publisher certificates when checking for updates. Valid options: 'true', 'false', and undef. Default: undef.

If 'true', the WSUS server distributes signed non-Microsoft updates. If 'false', the WSUS server only distributes Microsoft updates.

#### `auto_install_minor_updates`

Determines whether to silently install minor updates automatically. Valid options: 'true', 'false', and undef. Default: undef.

If 'true', Windows installs minor updates without user interaction. If 'false', Windows treats them as any other update, which depends on other settings such as [`auto_update_option`][].

#### `auto_update_option`

Sets the automatic update option you would like to use. Valid values: 'NotifyOnly', 'AutoNotify', 'Scheduled', and 'AutoInstall'. You can also refer to these four values using integers 2 through 5, respectively. Default: undef.

See the `AUOptions` key values on the [Microsoft TechNet documentation][TechNet] for detailed descriptions of these options. In summary:

* '**NotifyOnly**': Notifies users before downloading updates.
* '**AutoNotify**': Automatically downloads updates and notifies users.
* '**Scheduled**': Automatically downloads updates and schedules automatic installation.
  * If set to this value, [`scheduled_install_day`][] and [`scheduled_install_hour`][] are **required**.
  * This parameter must be set to this value to use [`reschedule_wait_time_minutes`][].
* '**AutoInstall**': Requires fully automatic updates that users can configure if allowed.

#### `detection_frequency_hours`

Sets an interval in hours for clients to check for updates. Valid values: integers 1 through 22. Default: undef.

If this [enabled parameter][] has a valid value, Puppet sets the `DetectionFrequency` registry key to its value and the `DetectionFrequencyEnabled` Boolean registry key to 'true'. Otherwise, Puppet sets `DetectionFrequencyEnabled` to 'false' and Windows ignores the value of `DetectionFrequency`, falling back to the Windows default value of 22 hours.

#### `disable_windows_update_access`

Determines whether non-administrators can access Windows Update. Valid options: 'true' (disable access), 'false' (enable access), and undef. Default: undef.

#### `elevate_non_admins`

Determines which security groups can approve or refuse updates. Valid options: 'true', 'false', and undef. Default: undef.

If 'true', members of the Users group can approve or refuse updates. If 'false', only members of the Administrators group can approve or refuse updates.

#### `enable_status_server`

Determines whether Puppet also sets the `WUStatusServer` registry key, which sets the client status reporting destination. Valid options: 'true', 'false', and undef. Default: undef.

If this parameter is set to true, Puppet sets the value for the `WUStatusServer` registry key to the [`server_url`][] parameter's value. Therefore, when setting this parameter to true, you **must** also set the `server_url` parameter to a valid URL or your Puppet run will fail with an error.

If `enable_status_server` is set to 'false', Puppet removes the `WUStatusServer` registry key.

**Note**: Windows [requires][TechNet] the same value for `WUStatusServer` and `WUServer`, so wsus_client does not provide an option to set a different status server URL.

#### `no_auto_reboot_with_logged_on_users`

Determines whether to automatically reboot while a user is logged in to the client. Valid options: 'true', 'false', and undef. Default: undef.

If 'true', Windows will not restart the client after installing updates, even if a reboot is required to finish installing the update. If 'false', Windows notifies the user that the client will restart 15 minutes after installing an update that requires a reboot.

#### `no_auto_update`

Disables automatic updates. Valid options: 'true', 'false' (automatic updates enabled), and undef. Default: undef.

Windows disables automatic updates when this parameter is set to 'true' and enables them if it's set to 'false'.

#### `purge_values`

Determines whether Puppet purges values of unmanaged registry keys under the `WindowsUpdate` parent key. Valid options: Boolean. Default: 'false'.

#### `reboot_relaunch_timeout_minutes`

Sets a delay in minutes to wait before attempting to reboot after installing an update that requires one. Valid values: integers 1 through 1440. Default: undef.

If this [enabled parameter][] has a valid value, Puppet sets the `RebootRelaunchTimeout` registry key to its value and the `RebootRelaunchTimeoutEnabled` Boolean registry key to 'true'. Otherwise, Puppet sets `RebootRelaunchTimeoutEnabled` to 'false' and Windows ignores the value of `RebootRelaunchTimeout`, falling back to the Windows default value of 10 minutes.

#### `reboot_warning_timeout_minutes`

Sets how many minutes users can wait before responding to a prompt to reboot the client after installing an update that requires a reboot. Valid values: integers 1 through 30. Default: undef.

If this [enabled parameter][] has a valid value, Puppet sets the `RebootWarningTimeout` registry key to its value and the `RebootWarningTimeoutEnabled` Boolean registry key to 'true'. Otherwise, Puppet sets `RebootWarningTimeoutEnabled` to 'false' and Windows ignores the value of `RebootWarningTimeout`, falling back to the Windows default value of 5 minutes.

#### `reschedule_wait_time_minutes`

Sets how many minutes the client's automatic update service waits at startup before applying updates from a missed scheduled update. Valid values: integers 1 through 60. Default: undef.

This [enabled parameter][] is used only when automatic updates are enabled and [`auto_update_option`][] is set to 'Scheduled' or '4'. If this parameter is set to a valid value, Puppet sets the `RescheduleWaitTime` registry key to that value and the `RescheduleWaitTimeEnabled` Boolean registry key to 'true'. Otherwise, Puppet sets `RescheduleWaitTimeEnabled` to 'false' and Windows ignores the value of `RescheduleWaitTime`, falling back to the Windows default behavior of re-attempting installation at the next scheduled update time.

#### `scheduled_install_day`

Schedules a day of the week to automatically install updates. Valid values: 'Everyday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', and 'Saturday'. You can also refer to these eight values using the integers 0 through 7, respectively. Default: undef.

This parameter depends on a valid [`scheduled_install_hour`][] value and is **required** when [`auto_update_option`][] is set to 'Scheduled' or '4'.

#### `scheduled_install_hour`

Schedules an hour of the day to automatically install updates. Valid values: an integer from 0 through 23. Default: undef.

This parameter depends on a valid [`scheduled_install_day`][] value and is **required** when [`auto_update_option`][] is set to 'Scheduled' or '4'.

#### `server_url`

Sets the URL at which your WSUS server can be reached. Valid options: fully qualified URL starting with 'http' or 'https', including protocol and port; 'false'; or undef. Default: undef.

When set to a URL, Puppet sets the `WUServer` registry key to this parameter's value and the `UseWUServer` registry key to '1' (true). 

If this parameter is set to 'false', Puppet sets `UseWUServer` to false, disabling WSUS updates on the client. If undefined, Puppet does not manage `WUServer` or `UseWUServer`.

Even if HTTPS is required for authentication, you can use 'http' URLs instead of 'https'. WSUS automatically switches to an HTTPS connection when required and increments the provided port by 1. For example, if the `server_url` is 'http://myserver:8530' and the WSUS server requires HTTPS access, the client automatically uses 'https://myserver:8531' to authenticate, then downloads the updates without encryption via the `server_url`. This performs better than using SSL to encrypt binary downloads.

**Note**: The `server_url` parameter is central to using wsus_client to manage updates from a WSUS server. While not strictly required to use the class, note that you must manage the `WUServer` and `UseWUServer` registry keys yourself if you do not set `server_url` and [`enable_status_server`][].

#### `target_group`

Sets the client's target group. Valid values: a string. Default: undef.

This [enabled parameter][] is only respected when the WSUS server allows clients to modify this setting via the [`TargetGroup` and `TargetGroupEnabled`][TechNet] registry keys.

### Enabled Parameters

Several `wsus_client` parameters modify two registry keys, one with a value and the other with a Boolean switch. These parameters, known as **enabled parameters**, modify both keys only when assigned a value other than 'false'.

For example, if the [`reschedule_wait_time_minutes`][] parameter takes a valid integer value from '1' to '60', Puppet sets the `RescheduleWaitTimeEnabled` registry key's value to '1' (true). If set to an invalid value or left undefined, Puppet sets the registry key to '0' (false), which disables the feature.

The module's enabled parameters are:
* [`detection_frequency_hours`][]
* [`reboot_relaunch_timeout_minutes`][]
* [`reboot_warning_timeout_minutes`][]
* [`reschedule_wait_time_minutes`][]
* [`target_group`][]

## Limitations

This module requires clients running Windows Server 2003 or newer, and a configured and active [WSUS server][] to use all of the module's options except [`purge_values`][]. For detailed compatibility information, see the [supported module compatibility matrix](https://forge.puppetlabs.com/supported#compat-matrix).

## Development

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can't access the huge number of platforms and myriad hardware, software, and deployment configurations that Puppet is intended to serve. We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things. For more information, see our [module contribution guide](https://docs.puppetlabs.com/forge/contributing.html). To see who's already involved, see the list of [contributors](https://github.com/puppetlabs/puppetlabs-wsus_client/graphs/contributors).
