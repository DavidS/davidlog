---
title: 'Puppet Module Skeleton'
category: puppet
tags: puppet
---

At the [Puppet Contributor Summit 2015 Gent](http://cfgmgmtcamp.eu/puppet.html)
I [rediscovered](../2015-02-04-puppet-future-parser)
[@garethr](https://twitter.com/garethr)'s wonderful
[puppet-module-skeleton](https://github.com/garethr/puppet-module-skeleton). It
plugs into the puppet module face and enables you to use `puppet module
generate myname-modulename` and get a working sekelton with all testing goodies
enabled.

Sadly there were some bring-up issues, which he now started to adress, adding a
[travis job](https://travis-ci.org/garethr/puppet-module-skeleton) to keep it
that way.  More help is always welcome to improve this resource.

# Advanced usage

Gareth's tool is great to create a new module. For working with existing
modules, [modulesync](https://github.com/puppetlabs/modulesync) is the way to
go. This tool can be configured with a set of templates and data to keep all
the tedious meta-bits in a set of a big number of modules aligned.

To cover all bases, modulesync needed a [small
modification](https://github.com/puppetlabs/modulesync/pull/36). Now I'm
porting over Gareth's skeleton into a modulesync config, so I can apply this to
all [my modules](https://github.com/DavidS).

I'm making good progress and will update you as soon as I've got something
proper to show.
