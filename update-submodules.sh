#!/usr/bin/env bash
set -e

echo updating:
git pull

echo getting latest:
git submodule update --init --recursive

