#!/usr/bin/env bash
set -e

echo updating:
git pull

echo initting submodules:
git submodule update --init --recursive

echo pulling latest:
git submodule foreach "git checkout -q `git remote show origin | sed -n '/HEAD branch/s/.*: //p'` && git pull -q"

