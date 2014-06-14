#!/usr/bin/env bash

echo Resetting...
git submodule foreach --quiet git reset --hard
echo Checking out master...
git submodule foreach --quiet git checkout master > /dev/null
echo Pulling...
git submodule foreach --quiet git pull -q

echo Done.

