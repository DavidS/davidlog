---
title: 'The Foreman, provisioning and more...'
category: puppet
tags: puppet foreman
---

Today I hit [#5883](http://projects.theforeman.org/issues/5883) again, when a
customer configured a host a few days ago, but only came around to actually
booting it yesterday. The nasty detail is that everything still works, except
for acknowledging the build success at the end. Discussing that on the [foreman
irc channel](irc://#theforeman@freenode.net) lead to my last comment on that
bug report. Currently I'm leaning towards making the tokens infinite until the
build is finished by having /unattended/built called. I might even be able to
implement that, although Dominic said that that's 1.7 material. So it'll be a
while until it reaches production.
