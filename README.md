# wsus_client

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
    * [What wsus_client affects](#what-wsus_client-affects)
3. [Setup](#setup)
    * [Beginning with wsus_client](#beginning-with-wsus_client)
4. [Usage](#usage)
    * [Schedule updates](#schedule-updates)
5. [Reference](#reference)
6. [Limitations](#limitations)
7. [Development](#development)

## Overview

The Windows Server Update Service (WSUS) lets Windows administrators manage operating system updates using their own servers instead of Microsoft's Windows Update servers.

## Module Description

This module configures Puppet agents to schedule update downloads and installations from a WSUS server, manage user access to update settings, and configure automatic updates.

### What wsus_client affects

This module modifies registry keys in `HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate`. For details about how registry key-driven WSUS configuration works, see the [Microsoft TechNet documentation](https://technet.microsoft.com/en-us/library/dd939844.aspx).

**Note**: Because this module modifies registry keys on clients, it is incompatible with Group Policy Objects that manage the same WSUS settings. **Do not use wsus_client to configure WSUS access or automatic updates if you use Group Policies to configure such options on clients**, as doing so can lead to unexpected behavior. Instead, consult Microsoft's documentation on [configuring automatic updates using Group Policy](https://technet.microsoft.com/en-us/library/dd939933.aspx).

## Setup

To use wsus_client, you must have a configured and running WSUS server, and your clients must run Windows Server 2003 or newer. For more information about deploying WSUS, see Microsoft's [WSUS Deployment Guide](https://technet.microsoft.com/en-us/library/dd939906.aspx).

To install this module on your Puppet server, run this command:

~~~
$ puppet module install [--modulepath <PATH>] puppetlabs/wsus_client
~~~

If necessary, use the optional `--modulepath` argument to specify your Puppet server's `modulepath`.

### Beginning with wsus_client

To have the client use a WSUS server and set the server's location, declare the `wsus_client` class with the WSUS server's url in the `server_url` parameter.

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

Clients can report update events to a WSUS status server as defined by the `WUStatusServer` registry key, which must have the same value as the `WUServer` policy to be valid for automatic updates. For details, see the [Microsoft TechNet documentation](TechNet).

To report the client's status to the WSUS server, use the `enable_status_server` parameter. For example, to configure a client to use `http://myserver:8530` for both updates and status reporting, declare this class:

~~~ puppet
class { 'wsus_client':
  server_url           => 'http://myserver:8530',
  enable_status_server => true,
}
~~~

## Reference

For information on the classes and types, see the [REFERENCE.md](https://github.com/puppetlabs/puppetlabs-wsus_client/blob/main/REFERENCE.md).

## Limitations

This module requires clients running Windows Server 2003 or newer, and a configured and active [WSUS server](https://technet.microsoft.com/en-us/library/hh852338.aspx) to use all of the module's options except `purge_values`. For detailed compatibility information, see the [supported module compatibility matrix](https://forge.puppet.com/supported#compat-matrix).

## Development

If you would like to contribute to this module, please follow the rules in the [CONTRIBUTING.md](https://github.com/puppetlabs/puppetlabs-wsus_client/blob/main/CONTRIBUTING.md). For more information, see our [module contribution guide](https://puppet.com/docs/puppet/latest/contributing.html). To see who's already involved, see the list of [contributors](https://github.com/puppetlabs/puppetlabs-wsus_client/graphs/contributors).
