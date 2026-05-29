#!/usr/bin/env zsh
set -e

echo "--- updating repo:"
git pull

echo "--- updating submodules:"
git submodule update --init --recursive
git submodule foreach zsh -c '
  git fetch --all --prune
  git remote set-head origin --auto >/dev/null
  branch=${$(git symbolic-ref --short refs/remotes/origin/HEAD)#origin/}
  git checkout -q "$branch"
  git pull --ff-only -q
'

echo "--- stowing:"
stow .
