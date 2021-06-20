#!/bin/bash

set -e

cd /srv/davidlog/git/

git annex lock .
git commit -m "lock server" || true # if no changes
JEKYLL_ENV=production bundle exec jekyll build --strict --verbose --destination /srv/davidlog/site

echo "Build Successful"