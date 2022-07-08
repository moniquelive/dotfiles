#!/usr/bin/env bash
set -e

echo updating:
git pull

echo initting submodules:
git submodule update --init --recursive

echo pulling latest:
git submodule foreach "git checkout -q main || git checkout -q master && git pull -q"

