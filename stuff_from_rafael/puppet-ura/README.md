User Rights Assignments
=======================

[![Puppet Forge Version](http://img.shields.io/puppetforge/v/camptocamp/ura.svg)](https://forge.puppetlabs.com/camptocamp/ura)
[![Puppet Forge Downloads](http://img.shields.io/puppetforge/dt/camptocamp/ura.svg)](https://forge.puppetlabs.com/camptocamp/ura)
[![Build Status](https://img.shields.io/travis/camptocamp/puppet-ura/master.svg)](https://travis-ci.org/camptocamp/puppet-ura)
[![Coverage Status](https://img.shields.io/coveralls/github/camptocamp/puppet-ura.svg)](https://coveralls.io/r/camptocamp/puppet-ura?branch=master)


## Usage

```puppet
user_right { 'seincreasequotaprivilege':
  ensure => present,
  sid    => ['CORP\domain', 'CORP\entadmin'],
}
```


## Split 

Add users to right from different contexts:

```puppet
user_right { 'seincreasequotaprivilege':
  ensure => present,
}

user_right_assignment { 'seincreasequotaprivilege for admins':
  right  => 'seincreasequotaprivilege',
  sid    => ['CORP\domain', 'CORP\entadmin'],
}

user_right_assignment { 'another right':
  right  => 'seincreasequotaprivilege',
  sid    => ['CORP\domain', 'CORP\entadmin'],
}
```

## Ensure absence

```puppet
user_right { 'seincreasequotaprivilege':
  ensure => absent,
}
```
