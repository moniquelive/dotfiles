#!/usr/bin/env bash
set -e

echo updating:
git submodule update

echo getting latest:
git submodule foreach --quiet '/bin/echo -n "$path: "; git reset --hard; git checkout -q master; git pull -q'

