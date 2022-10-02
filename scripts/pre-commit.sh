#!/bin/bash

# Make sure we're in the repo root directory
ROOT=$(git rev-parse --show-toplevel)
cd "$ROOT"

# Stash any uncommitted changes
# Makes sure these tests are only being applied to what's stage
# But get all config files back out stash or the tests will break :)
git stash --include-untracked --keep-index >/dev/null
git restore --source=stash@{0} -- config/.

# Run rubocop
echo -e "\nRunning Rubocop checks"
echo "---------------------------------------------------------"
rubocop src
RET=$?
if [[ $RET -ne 0 ]]; then
  echo "Unable to commit. Errors in Rubocop"
  # Get any working changes back out of stash
  git stash pop -q --index
  exit $RET
fi

# Run test suite
echo -e "\nRunning Tests"
echo "---------------------------------------------------------"
ruby test/jrpl_test.rb
RET=$?
if [[ $RET -ne 0 ]]; then
  echo "Unable to commit. Some tests not passed"
  # Get any working changes back out of stash
  git stash pop -q --index
  exit $RET
fi

# Get any working changes back out of stash
git stash pop -q --index >/dev/null

# Protect the config files
scripts/protect_configs.rb

# Over-write any staged config files with their protected version
for f in $(git diff --cached --name-only --diff-filter=ACM | grep "config/.*yml"); do
  git add $f
done