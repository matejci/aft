#!/usr/bin/env bash

echo "Pre-commit hook"
./scripts/rubocop.bash

if [ $? -ne 0 ]; then
 echo "Rubocop is not satisfied! Please, clean up your code."
 exit 1
fi
