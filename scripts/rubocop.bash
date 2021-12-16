#!/usr/bin/env bash

cd "${0%/*}/.."

git diff --staged --quiet --exit-code
if [ $? -eq 0 ] ; then
 echo "Nothing to check for rubocop"
 exit 0
fi

set -e

echo "Running rubocop"
git diff --cached --name-only --exit-code | xargs ls -1 2>/dev/null | grep '\.rb$' | xargs bundle exec rubocop
