---
title: 'DebConf 14 review'
tags: debian video review
---

# DebConf 14

While I could not attend [Debconf 14](http://debconf14.debconf.org/) in person,
reviewing the [video
coverage](http://meetings-archive.debian.net/pub/debian-meetings/2014/debconf14/webm/)
has enabled me to learn new and interesting things about what's going on.
Here're a few highlights.

  * [A glimpse into a systemd
    future](http://meetings-archive.debian.net/pub/debian-meetings/2014/debconf14/webm/A_glimpse_into_a_systemd_future.webm)
    by Josh Triplett: enumerates a few features that should/could be used in a
    Debian context to improve integration with systemd. Sadly the video has a
    few corruption issues, so I hope that the video team (I reported the issue)
    can issue an improved version.
  * [Quit logging or data
    minimization](http://meetings-archive.debian.net/pub/debian-meetings/2014/debconf14/webm/Quit_logging_or_data_minimization_in_Debian.webm)
    by Daniel Gillmor: Food for thought. Daniel's entry point is that to
    protect "our users" privacy, default configurations should strive to
    minimize logging. As one egregious example, apache keeps a full access (IP,
    URL, username, referer) log for 52 weeks. In the following discussion, many
    interesting points were touched. From the need to have full logs available
    for debugging and forensic, over the possibilities to redact logs after "a
    while" to the necessity that logs mustn't be kept on permanent storage if
    one wants to be safe from subpoenas.
  * [Reproducible Builds for Debian a year
    later](http://meetings-archive.debian.net/pub/debian-meetings/2014/debconf14/webm/Reproducible_Builds_for_Debian_a_year_later.webm)
    by Jérémy Bobbio: With a few tricks, a large number of packages can be made
    to produce bit-for-bit identical outputs when building from source. This
    opens up a wide variety of benefits from trivial performance improvements
    by reusing non-modified bits to the very serious security properties of
    being able to independently verify the build, like the Tor Browser project
    does.
  * [Weapons of the
    Geek](http://meetings-archive.debian.net/pub/debian-meetings/2014/debconf14/webm/Weapons_of_the_Geek.webm)
    by Biella Coleman: a very interesting view into Anonymous workings,
    evolition and psyche.
  * [debci and the Debian Continuous Integration
    project](http://meetings-archive.debian.net/pub/debian-meetings/2014/debconf14/webm/debci_and_the_Debian_Continuous_Integration_project.webm)
    by Antonio Terceiro: debci runs tests against installed binaries if and
    when they or any of their dependencies change. Integrating this properly
    into a maintainer's workflow should reduce FTBFS counts and provide a way
    to run autopkgtests regularily.
  * [dgit: treat the archive as a git
    remote](http://meetings-archive.debian.net/pub/debian-meetings/2014/debconf14/webm/dgit_treat_the_archive_as_a_git_remote.webm)
    by Ian Jackson: A two-way gateway between the Debian archive and git. `dgit
    clone` fetches the source and all available git history from the archive
    and `dgit push` uploads a compiled package to incoming. Very neat and
    useful. I'm looking forward to the time when this is usable for non-DDs.
    Also Ian still needs to solve a bunch of integration issues to catch up in
    patch management functionality with other workflows, especially around
    quilty packages.
  * [debdry: Debian Dont Repeat
    Yourself](http://meetings-archive.debian.net/pub/debian-meetings/2014/debconf14/webm/debdry_Debian_Dont_Repeat_Yourself.webm)
    by Enrico Zini: A new approach to reduce packaging overhead. I like it!
  * [Q&A with Linus
    Torvalds](http://meetings-archive.debian.net/pub/debian-meetings/2014/debconf14/webm/QA_with_Linus_Torvalds.webm):
    A very interesting session. Obviously Linux feels at home and often talks
    about "us" programmers. His views about the lack of binary compatibility
    guarantees of distros and the problems this generates for application
    developers sound very sensible. His exaple of subsurface is a mixed bag
    though as its current version is already packaged in Debian. Looking at the
    debci talk, and other activities DDs do, I still think that distros can
    bring value to the table, and - indeed - have to bring to stay relevant.
    Ever since unit tests and friends have entered the stage, I'm chased by the
    feeling that distros should be much more involved in upstream development.
    Why can't I have an automatically up-to-date SCM snapshot of all
    development versions in experimental (or a new suite)?
