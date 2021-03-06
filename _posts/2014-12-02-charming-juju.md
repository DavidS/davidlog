---
title: 'Charming Juju'
tags: ubuntu juju vagrant virtualbox
---

For fun and profit I tried out juju today. Following basically the
[tutorial](https://juju.ubuntu.com/docs/config-vagrant.html) to test it out
with vagrant, I've created a Vagranfile to load several
[trusty-amd64-juju](http://cloud-images.ubuntu.com/vagrant/trusty/current/) boxes
to juju on them.

Color me not impressed.

* The juju image flavor is twice the size (+300MB) of the normal trusty vagrant
  image.
* When provisioning the trusty-juju box, it downloads even more stuff from the
  internet to finish the installation.
  * ... using a progress bar that totally breaks in vagrant (one line per
    character, shows time to finish and current d/l speed).
  * ... 228MB, if I read this correctly.
  * ... deploying to an lxc container within the virtual box.
  * ... using an internal non-routed IP for this container.

* Adding nodes to the main juju host (using the normal trusty vagrant image)
  fails since juju configures a proxy for apt's http method, which is running
  in a container on the juju host. Since the container is using a local bridge,
  it is not reachable from the new box.
  * fixed the communication problem by manually adding the appropriate route on
    the clients.
  * ... only to find out, that the squid is -- of course -- configured to only
    allow access from the lxc network. Added more sed to Vagrantfile. Fixed.
  * ... only to find that the squid has "slight" configuration problems and
    fails to properly forward files from the mirrors. More sed fixes.
  * ... except that this was no immediate squid problem, but some weird DNS
    issue that went away by itself after a few tries.

    > Heavy voodoo here.  I can't even believe you are reading this.
    > Are you crazy?  Don't even think about adjusting these unless
    > you understand the algorithms in comm_select.c first!
    > -- the squid docs about [dns parameters](http://www.squid-cache.org/Doc/config/min_dns_poll_cnt/)

At this point I had a mostly working juju main box and a few added agents running.

Phew!
