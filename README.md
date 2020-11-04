# Puppet module for Windows Local Security Policy types

#### Table of Contents
1. [Overview](#overview)
2. [Usage](#usage)
2. [Types](#types)
   * [so_privilegerights](#so_privilegerights_type)
   * [so_privilegerights_fragment](#so_privilegerights_fragment_type)
   * [so_registryvalue](#so_registryvalue_type)
   * [so_systemaccess](#so_systemaccess_type)
3. [Providers](#providers)
4. [Puppet_X](#puppetx)

## Overview
The securityoptions providers use the secedit.exe utility from microsoft to manage the settings.  Specifically, it managed the following sections of the secedit output: Privilege Rights, Registry Values, System Access.  It does not manage the Event Audit section.

The three providers share a common parent, windows_securityoptions.  When the first resource type is instantiated, the secedit.exe command is run and C:\ProgramData\PuppetLabs\puppet\cache\secedit_exports.txt is created.  This same file is read by all the providers.

The secedit_mapping.json file is manually maintained and originated from local_security_provider (https://forge.puppet.com/ayohrling/local_security_policy).  It provides for type validity checking as well as for translating between long and short names.  The short names are the entries found in the secedit export and the long names are the longer, descriptive names found in the group policy mmc.

We created this new module because we needed the ability to dynamically modify the User Rights Assignment definitions based on profiles/classes that were in scope for the desired puppet role.  There was not a way to use hiera to accomplish this, and unfortunately neither was module based hiera.  After identifying this need, it was determined that we could also consolidate a lot of the code and drastically reduce redundancy of code.

It was decided no to support the Audit section of the secedit file, as most current systems implement the Advanced Audit Configuration, which is handled by the auditpol.exe utility and no longer uses the previous, basic configuration foudn in the secedit configuration.

## Types

### so_privilegerights_type
This type configures the user rights assignments in Windows.  The so_privilegerights resource fully manages the resource, meaning that all security identifiers must be listed in the sid property.  In the example below, the machine will be configured to allow the domain user user1, the domain group group1, and the built-in Administrators group to Change the time zone.
```puppet
so_privilegerights{'setimezoneprivilege':
  ensure => present,
  sid    => ['DOMAIN\user1','BUILTIN\Administrators','DOMAIN\group1'],
 }
```

### so_privilegerights_fragment_type
In Windows, the User Rights Assignments are typically managed via GPOs which allow for a merging across multiple GPOS.  A typical scenario would be that domain admins confiugre a baseline GPO that has all of the default User Rights Assignment listed and then for machines running IIS or SQL Server, a second GPO would be created and applied that had the IIS or SQL specific security objects given permissions to the appropriate user rights.  So when the GPO is applied to the machine the 2 GPOs are then merged.

In puppet this works differently, as we can only manage a particular resource one time.  This means we have to merge the data prior to applying the resource.

A common scenarios would be IIS.  IIS requires that users running IIS processes be granted a few User Rights Assignments in order to function properly.  During the installation of IIS on a Windows machine, the built-in IIS_IUSRS group would be granted the necessary User Right Assignments and then the users would be added to this local group.

However, if we are managing this User Right with puppet, then we would not necessarily know before hand whether this particular machine would need the extra settings.  So the so_privilegerights_fragment type can be used to add additional security objects to the User Rights Assignment.  It does so by injecting fragments into the catalog that are then retrieved by the provider.

So I can create an IIS profile that installs IIS, and as part of the IIS profile I can include the 6 so_privilegerights_fragments so that anytime IIS is installed using the puppet profile, the correct user rights are applied to the machine
```puppet
so_privilegerights_fragment { 'iis_seassignprimarytokenprivilege':
  right => 'seassignprimarytokenprivilege',
  sid   => ['BUILTIN\IIS_IUSRS'],
}
```
### so_registryvalue_type
### so_systemaccess_type

## Providers
### so_privilegerights
### so_registryvalue
### so_systemaccess

[![Puppet Forge Version](http://img.shields.io/puppetforge/v/camptocamp/windows_securityoptions.svg)](https://forge.puppetlabs.com/camptocamp/windows_securityoptions)
[![Puppet Forge Downloads](http://img.shields.io/puppetforge/dt/camptocamp/windows_securityoptions.svg)](https://forge.puppetlabs.com/camptocamp/windows_securityoptions)
[![Build Status](https://img.shields.io/travis/camptocamp/puppet-windows_securityoptions/master.svg)](https://travis-ci.org/camptocamp/puppet-windows_securityoptions)
[![Puppet Forge Endorsement](https://img.shields.io/puppetforge/e/camptocamp/windows_securityoptions.svg)](https://forge.puppetlabs.com/camptocamp/windows_securityoptions)
[![By Camptocamp](https://img.shields.io/badge/by-camptocamp-fb7047.svg)](http://www.camptocamp.com)

#### Reference

See [REFERENCE.md](REFERENCE.md)

