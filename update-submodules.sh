#!/usr/bin/env bash
set -e

echo updating:
git pull

echo initting submodules:
git submodule update --init --recursive

echo pulling latest:
git submodule foreach "git checkout -q $(git_main_branch) ; git branch; git pull -q"

