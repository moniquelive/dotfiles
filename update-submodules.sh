#!/usr/bin/env bash
set -e

function git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local ref
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk}; do
    if command git show-ref -q --verify $ref; then
      echo ${ref:t}
      return
    fi
  done
  echo master
}

echo updating:
git pull

echo initting submodules:
git submodule update --init --recursive

echo pulling latest:
git submodule foreach "git checkout -q $(git_main_branch) ; git branch; git pull -q"

