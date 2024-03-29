---
title: "Hello, Rabbithole"
category: puppet
tags: puppet testing retrospec exim travisci beaker docker vagrant fullstack clamav
---

> Please note that this post is a linear and unedited brain dump of what I did. Many things might have changed meanwhile, and I may have learned how to do things better. This is an experiment in progress.

This is a continuation of [last week's post](/posts/2016-04-03-containing-docker/), refreshing my [exiscan module](https://github.com/DavidS/puppet-exiscan) using [retrospec-puppet](https://github.com/nwops/puppet-retrospec), and a few other nifty technologies. In the last installment I contained docker in a virtualbox to avoid magic action at a distance on my desktop (dialogs popping up, audio being muted).

## Picking up the Pieces

Last week, I gave up on this, after provisioning a fresh box with a vboxsf for `/var/lib/docker`, which confused docker to the point of refusing to work at all. Looking at it with fresh eyes, I have to admit, that it was a very optimistic approach. Rebuilding the box without this mount succeeded, and toock little more than ten minutes.

While waiting on the box to build, I created a unprivileged user to try out whether that fixed my issues, but of course, these being kernel things, and docker running as root, this did change a thing. Finally I could try to hack the boot sequence to avoid fondling the kernel in unspeakable ways, but the box is already running the tests, and I couldn't be bothered. Rome wasn't built in a day either.

## Running the Tests

Now that the tests are running without annoyance, I can continue working on the actual code.

## Accelerating docker

Jinxed it. For some reason installing packages in docker in the box causes 100% iowait and approx 150kB/s write I/O in the box, while the host is idling. Failing to spot any obvious causes, I suspect the linked_clone option, and disable that one. Additionally I add strace, and lsof to the biult-in tools for the docker image, so next time around I can have a more in-depth look. Writing this, I also need to check next time whether the same I/O "performance" is seen **outside** the docker container in the box. Maybe docker's underlying FS layering is botching up?

Meanwhile my handiest bash function gets another go:

```
function unfuck() { vagrant destroy -f "$@" && vagrant up "$@" ; }
```

Installing packages in the vbox is fast and has a peak I/O bandwidth of 32MB/s. Reading up on docker [storage drivers](https://docs.docker.com/engine/userguide/storagedriver/selectadriver/) highlights how the default `aufs` driver apparantly is not suited for "high write activity", suggesting the LVM/devicemapper driver instead.

### Adding a second disk

It's really **quite** easy, and only took me an hour or so to figure out.

```
config.vm.provider "virtualbox" do |vb|
  disk_image = "/tmp/docker-lvm.vdi"

  vb.customize ['createhd', '--filename', disk_image, '--size', 500 * 1024] unless File.exists?(disk_image)
  vb.customize ['storagectl', :id, '--add', 'sata', '--name', 'SATA', '--hostiocache', 'off' ]
  vb.customize ['storageattach', :id, '--storagectl', 'SATA', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', disk_image]
end
```

Of course, the `disk_image` is not bound to the life cycle of the vagrant box, and vagrant doesn't support any extended operations, other than calling out to the underlying hypervisor.

### Configuring docker

[Docker's devicemapper documentation](https://docs.docker.com/engine/userguide/storagedriver/device-mapper-driver/) is pretty comprehensive.

Beware the traps:

```
# /etc/defaults/docker
# THIS FILE DOES NOT APPLY TO SYSTEMD
```

It also points to this gem of [documentation](https://docs.docker.com/engine/admin/systemd/): "In this example, we’ll assume that your docker.service file looks something like: [...]". I installed the thing from your packages. You should perfectly well know how your config looks like!

The new provision section for docker on DM looks now like this:

```
DISK=$(/bin/echo -e 'sda\nsdb' | grep -v $(ls /dev/disk/by-id/ata-VBOX_HARDDISK_VB????????-????????-part1 -la | cut -d/ -f 7 | cut -b 1-3))

pvcreate /dev/$DISK
vgcreate docker /dev/$DISK
lvcreate -L 90G -n data docker
lvcreate -L 4G -n metadata docker
mkdir -p /etc/systemd/system/docker.service.d

cat > /etc/systemd/system/docker.service.d/storage-driver.conf <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/docker daemon -H fd:// --storage-driver=devicemapper --storage-opt dm.datadev=/dev/docker/data --storage-opt dm.metadatadev=/dev/docker/metadata
EOF

systemctl daemon-reload
systemctl enable docker
systemctl restart docker
```

It turns out that the linux kernel will hold true to its claim that block device initialization order is random. The next try failed with `Device /dev/sda not found (or ignored by filtering).` because `sdb` is now the second disk. This causes the dance with inspecting the `/dev/disk/by-id` symlinks.

After jumping through enough hoops, dpkg package installation is still slow af. "Good" that I'm "learning" on my "personal" time "here".

## Back to the Desktop

Since docker on Debian 8 in a virtualbox doesn't want to cooperate at acceptable levels, I have to accept the fiddling with my devices and resume running docker directly on my main kernel. 2 minutes 22 seconds total runtime for a beaker run from scratch, and 1:55 when the caches are hot and the base beaker image is already built. I could probably shave off another 30 seconds by caching Debian and Puppet locally, or moving some of the setup code into the docker build command in the nodeset.

## Fixing the Test

Irrespective of the virt tech used to run the tests, they always failed the idempotency test:

```
Failures:

  1) exiscan is idempotent
     Failure/Error: expect(result.exit_code).to eq 0

       expected: 0
            got: 2

       (compared using ==)

     # ./spec/acceptance/exiscan_spec.rb:23:in `block (2 levels) in <top (required)>'
```

because of

```
Notice: /Stage[main]/Exiscan::Spamassassin/Service[clamav-daemon]/ensure: ensure changed 'stopped' to 'running'
```

poking into the docker container,

```
root@debian-8-x64:~# systemctl status clamav-daemon
● clamav-daemon.service - Clam AntiVirus userspace daemon
   Loaded: loaded (/lib/systemd/system/clamav-daemon.service; enabled)
   Active: inactive (dead)
           start condition failed at Sam 2016-04-09 17:35:12 UTC; 1min 35s ago
           ConditionPathExistsGlob=/var/lib/clamav/daily.{c[vl]d,inc} was not met
```

which can easily be fixed by waiting for freshclam to finish downloading the virus pattern definitions:

```
# freshclam needs time to download the patterns
# Instead of failing clamav-daemon, we wait for this to finish
exec { 'wait-for-freshclam':
  command => "/bin/bash -c 'while [ ! -d /var/lib/clamav/daily.cvd ]; do sleep 1; done'",
  creates => '/var/lib/clamav/daily.cvd',
  require => Service['clamav-freshclam'],
  before  => Service['clamav-daemon'],
}
```

That takes ... a while:

```
Error: /Stage[main]/Exiscan::Spamassassin/Exec[wait-for-freshclam]/returns: change from notrun to 0 failed: Command exceeded timeout
```

It would have helped to check for existence (`-e`) instead of directory (`-d`).

But at least, now it works!

```
Finished in 2 minutes 45.4 seconds (files took 27.62 seconds to load)
2 examples, 0 failures

real	3m14.596s
```

## Conclusions

* I should rename this blog to "Do not ask how the sausages are made."
* Nesting virtualisation is bad for performance.

## Update

To stave off boredom, I upgraded the vagrant box to Debian "stretch", which is what I'm using on my desktop too. This has the kernel version 4.4.0-1 and suddenly the beaker tests run in 3m27s on hot caches. Not too bad - except for all the hassle.
