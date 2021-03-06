---
title: 'Tiny Puppet Experiments'
category: puppet
tags: puppet programming
---

# [Tiny Puppet](https://github.com/example42/puppet-tp) Experiments

Tiny puppet is a new idea by [Alessandro
Franceschi](https://github.com/example42) to provide a simple skeleton for
basic puppet modules. The intention is to provide a Proper Opinion on core
parameters. Alessandro talked to me about how there is still no totally
satisfying solution to defining the module data in TP.

Today I'll take a look at doing so.

Start with activating [travis support](https://travis-ci.org/DavidS/puppet-tp).
And immediately [upgrading all
gems](https://github.com/DavidS/puppet-tp/commit/1417b56c113d751193805567cccc1bb26d0a27de).
Now actually only a single spec
[fails](https://travis-ci.org/DavidS/puppet-tp/jobs/31401305). Progress! This
seems to be exactly the core problem Alessandro's been talking about.

To get a broader view on the problem space, I read R.I.Pienaar's
[module-data](https://github.com/ripienaar/puppet-module-data) module, and try
to ingest the potential capabilities of the [tp
face](https://github.com/example42/puppet-tp/blob/master/lib/puppet/face/tp.rb)
and everything else in the module.

One problem I see is how tp tries to shoehorn everything through the `tp::`
namespace, leading to twofold problems:

  1. Complex lookup logic (not yet implemented). This deviates from the lookup
     structure popularized by hiera. Breaking away from this means that hiera
     customizations cannot be re-used with this structure and users have to
     learn new rules.
  2. On the code side, this leads to definitions like

         tp::conf { 'redis::red.conf': ...

     which should better read

         redis::conf { 'red.conf': ...

Keeping with common hiera patterns for #1 would require some kind of
translation of actual arguments into the tp world. Since Alessandro's [Handy
Grail](http://www.example42.com/2013/06/15/the-handy-grail-of-modules-standards/)
post from last year, I was toying around with a convention-over-configuration
based approach to the issues laid out there. Maybe these ideas could be
combined here. Having a one-liner to pass arguments to a core tp define would
also make #2 easier.

To reality-check my experiment, I'm looking over
[puppetlabs-mysql](https://github.com/puppetlabs/puppetlabs-mysql) to get a
realistic view on the feasibility of converting the module to a tp core.

## puppetlabs-mysql notes

  * `mysql::params` looks like the seventh circle of Dante's hell. Luckily, the
    defaults are well factored, so converting to module-data should not be
    complex. Only tedious. There's only a single occurrence of a none
    parameter-default reference into `mysql::params`, so there're no other
    dependencies.

  * Core mysql parameters are managed via a generic `$override_options` hash,
    that is merged into defaults. These options are partly supplied by other
    params variables as they are distro-specific.

  * some parameters are deprecated, requiring a `$real_` variable. I can think
    of some hacks to workaround this by breaking into the databinding code and
    fixing things up there. I'm not sure that is implementable (or sensible)
    though.

    *TODO:* It's a general problem and thus should be addressed somehow.

  * `mysql::server::install` optionally creates the initial datadir. On the one
    hand this is laudable, since some distros choose to deliver mysql in a
    non-functioning state. On the other hand, this functionality is buried in a
    secondary class under a very strange conditional, mixing checks of the
    merged options with checks on the user-specified options. The former is
    annoying as it is not usable for multi-instance installations, the latter
    looks like a bug to me. Perhaps the original author wanted to avoid
    creating the datadir when the default location was used?

PS: Now Playing: [New Electro & House 2013 Chart Mix](https://www.youtube.com/watch?v=Q2SIoikPsBM&list=PLXnEiZMPaaLwvGvSZpc8ACea7vXD51ksC)
