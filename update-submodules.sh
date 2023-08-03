#!/usr/bin/env zsh
set -e

echo "--- updating:"
git pull

echo "--- initting submodules:"
git submodule update --init --recursive

echo "--- pulling latest:"
git submodule foreach zsh -c '
  plugins=(git)
  source $HOME/.oh-my-zsh/oh-my-zsh.sh

  git fetch --all -p
  git checkout -q $(git_main_branch)
  git branch
  git pull -q
'

echo "--- stowing:"
stow .
