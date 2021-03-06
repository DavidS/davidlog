---
title: 'The Great Bootstrap Shootout'
tags: ruby rails bootstrap programming
---

# The Great [Bootstrap](http://getbootstrap.com) Shootout

There seem to be three major ways to get bootstrap into your rails app.

  1. commit the CSS and JS as downloaded from http://getbootstrap.com
  2. [twitter-bootstrap-rails](https://github.com/seyhunak/twitter-bootstrap-rails)
  3. [bootstrap-sass](https://github.com/twbs/bootstrap-sass)

Things that make me go "hmmm". Three of them. Hmmm.

To explain: bootstrap is a CSS framework that uses a preprocessor called
[LESS](http://lesscss.org/) to make coding such a huge stylesheet bearable and
consistent. Named constants FTW! This is what #1 and #2 bring to the table. The
first in its statically precompiled glory and the second somewhat more
dynamically, but hidden in a gem.

Rails of course has its own CSS preprocessor called
[SASS](http://sass-lang.com/) hooked up into its [asset
pipeline](http://guides.rubyonrails.org/asset_pipeline.html). To enable
programmers to work with the tools they are familiar with, there is a whole
project to (automatically!) convert from less to sass. #3 brings the result of
this conversion and hooks it into the aforementioned asset pipeline, to be
compiled on deployment. Nice.

Except, that the `twitter-bootstrap-rails` gem has very nice and helpful helpers,
that can be used to build e.g. the navbar, which then go on and automatically
recognize which `menu_item` to `active`ate based on the current view. Which is
bad, since now we have to choose between two evils: *less*er functionality or
skip on the *sass*y integration. Ouch. To add insult to injury there is a
recent attempt at [extracting the
helpers](https://github.com/toadkicker/twbs_helpers) which would exactly fill
this gap, IFF it weren't for the fact that this was done in the most shady way
by copying the files into a new repository. Also it looks quite abandoned with
only two commits.

Anyways, I've uploaded both choices as
[twitter-bootstrap-rails](https://github.com/DavidS/hrdb/commit/13fae9a9cba6de287e816e33b582fc4153a7c057)
and
[bootstrap-sass](https://github.com/DavidS/hrdb/commit/e762a2f4e69061eeddab006df6c4a22249eff4ce)
to sleep over it.
