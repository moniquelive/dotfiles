#!/bin/sh
set -eu
printf '%s\n' 'Stow deployment is retired. Applying the live mise configuration instead.'
exec mise -C "$HOME" bootstrap "$@"
