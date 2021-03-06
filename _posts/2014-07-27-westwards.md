---
title: 'Westwards!'
tags: ruby rails programming
---

# Westwards!

Continuing from yesterday, I'll try to integrate
[Authlogic](https://github.com/binarylogic/authlogic) today. According to the
README, one needs a special `Model` and `Session` classes, which then can be
used to handle/implement all authentication concerns. After the README, it's
still not clear to me how to proceed. There is a [reference
implementation](https://github.com/binarylogic/authlogic_example/tree/master)
which contains more information about how to proceed. I go with that. And
almost immediate fail, due to changes in rails 3, which were already
[reported](https://github.com/binarylogic/authlogic_example/issues/21) in 2010.
Further browsing through the issues there reveals a [pull request updating the
README](https://github.com/binarylogic/authlogic_example/pull/20) to deal with
those changes. I wrangle much from the example repo into my own structure,
learning about [resetting the
database](http://stackoverflow.com/a/4116124/4918) and a little bit more about
[migrations](http://guides.rubyonrails.org/migrations.html). Some things are a
little bit of trial and error, as the README and the code do not always match
perfectly. Some things go wrong because the README update for rails 3 doesn't
match the [rails 4 way to
do](http://brettu.com/rails-daily-ruby-tips-160-rails-4-filter-parameter-logging-moved-to-initializers/)
things. When trying out the copied code, the `user_session` is still looking
for the `user` class, which - of course - doesn't exist, as I'd like to
authenticate `People`. Reading the
[code](https://github.com/binarylogic/authlogic/blob/master/lib/authlogic/session/klass.rb#L19)
reveals that the session has to be called like the `acts_as_authentic`. D'oh.
[Renaming stuff in rails](http://stackoverflow.com/a/11924254/4918) is not fun.
Really.

Of course, once this was [all
done](https://github.com/DavidS/hrdb/commit/4975db03421e603fa343dacc4da7f5b1a5a459fb),
it didn't work. Meh. After reconsidering the current state, I abandon Authlogic
and look around for other rails solutions to authentication.
[Sorcery](https://rubygems.org/gems/sorcery) is recommended on
[stackoverflow](http://stackoverflow.com/a/23384179/4918) and looks [good and
active](https://github.com/NoamB/sorcery/pulse). A refreshing change from
authlogic's five year old example repo.

Sorcery's rails 4 compatability shines in it's installation process. The
[commit](https://github.com/DavidS/hrdb/commit/8245fee20af64ba1dc7507c00cbc5e368e0a3286)
is much smaller, as it doesn't need a separate session, it integrates easily
into my existing model (although I had to manually fix up the migration). The
configuration is already a rails4 initializer. And finally, the hook-up to the
model is a single line.

Now for actually getting new users and authenticating. Following the
[authentication with sorcery
railscast](http://railscasts.com/episodes/283-authentication-with-sorcery)
more
[code](https://github.com/DavidS/hrdb/commit/94ea8b1c8907c7a14c6d0706ca938deab4282722)
[is](https://github.com/DavidS/hrdb/commit/07384136f379869859a1bb4b6097c13e55b9c1a4)
[added](https://github.com/DavidS/hrdb/commit/fa19fd614b4277df77147decbcc5e9af89b1ceb7).
This looks all quite straightforward and hackable. I like this. Now the
application can sign up, login and logout. Sorcery saves the day!

Now to some bones: add the actual data model. Since the number of users is
still in the single digits (zero), I take the liberty and change the initial
migration to [add more
columns](https://github.com/DavidS/hrdb/commit/be39fb09a90747027b8fc109a8cadefa37055ecc).

# Code Quality

Before driving on, I've set up the code coverage and code quality reporter from
[codeclimate.com](https://codeclimate.com).
[Commmit](https://github.com/DavidS/hrdb/commit/1c7280006fac636981a007e25c096b583c0f7ec3).
[Results](https://codeclimate.com/github/DavidS/hrdb). Time to add a little bit
of bragging to the
[README](https://github.com/DavidS/hrdb/commit/402e7928d694c9f2ef56d0d54dd113611931bc2a).

* Adding codecoverage adds another minute to the test runtime. That's basically
  double the current runtime.
* Completely untested code files are not counted against the coverage total on
  codeclimate.com. Therefore, adding the first test for an existing file
  actually reduces coverage, as the still-untested code is now counted as such.

To wrap up yesterday's TODOs, I also [added a
license](https://github.com/DavidS/hrdb/commit/9274b4018b2e0a3ca19b0fbcdc7f8c00706d049d).
Namely AGPL v3 or later.


# Adding projects

To start fleshing out the models, I next start adding projects. Every Person
can be associated with multiple Projects and every Project can have many
associated Persons.
[Commit](https://github.com/DavidS/hrdb/commit/5738ccc6841012c0fe92ba84513623d439a879f0).
Next a
[controller](https://github.com/DavidS/hrdb/commit/857cd2299b2da56937f72173f52c73991759589d)
and view for Projects. As it's already annoying to enter /new in the browser
for testing, I [add a few
links](https://github.com/DavidS/hrdb/commit/366d706036e9aa587aba22971675e43ad8bbd82e)
to the welcome page. Recommended reading:
[routing](http://guides.rubyonrails.org/routing.html). Implemented the
[complete
lifecycle](https://github.com/DavidS/hrdb/commit/e08cc0d781f47f8c74d0a141798b617230314dc7)
of projects and
[editing](https://github.com/DavidS/hrdb/commit/6fbdd63677e1018af4d53c65b9313ba92f55eba9).
Meanwhile code coverage is dropping like a rock, since I'm punting on those.
But the tests I have do not really test anything either, except successfull
execution of the controller, so the number's value is dubious at best.

## Next up: linking people and projects.

Read [Tutorial about Ajaxified Create and Destroy Actions](http://alx.bz/2012/03/06/ajax-on-rails-ajaxified-create-and-destroy-actions-for-has_manybelongs_to-related-models/), [HABTM Checkboxes](http://railscasts.com/episodes/17-habtm-checkboxes?view=asciicast), and finally a [stackoverflow answer](http://stackoverflow.com/a/3768207/4918) from 2010, claiming

> habtm isn't a popular choice these days, it's better to use has_many :through
> instead, with a proper join model in between. [...] a proper join model, with
> corresponding controller, allows you to easily add/remove origins with AJAX,
> using create/delete calls to the join model's controller.

Found a [nice plugin for two lists to move items from one to the
other](https://github.com/leikind/wice_assignment_lists), which is for
rails2(sic!). Nice, but no cake.

Even after (much) more reading, I come to the sad realization, that the SO
answer above, really seems to be the way to go: add a cusotm search control to
select people/projects and call out to the link table's controller to
add/delete connections. Changing the models will be a drag, but hopefully worth
the effort. Not satisfied with the last sentence I dig around more and find a
nice [blog post about habtm associations in
rails4](http://puneetpandey.com/2014/07/08/kick-off-first-rails-4-application-with-habtm-association/),
but the [provided code](https://github.com/puneetpandey/rails4-habtm) only uses
checkboxes to select association.

As a warm-up I've implemented searching by last name and returning of a JSON
result.
[Commit](https://github.com/DavidS/hrdb/commit/e5d1137cf1a634f3094f13c0380ea9c6d1203438).

# Next Steps

 * Add inline person search control to /projects/:id/edit
 * Add found person to people collection
 * Check that posting that back to the server changes the associated People

TODO:

 * Improve testing regime, when understanding rails better
 * l10n, when actually adding nice views
