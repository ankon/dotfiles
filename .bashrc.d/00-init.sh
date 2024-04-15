#!/bin/sh

_me=${BASH_SOURCE[0]}
if [ -L "${_me}" ]; then
	_me=$(readlink "${_me}")
fi
export DOTFILES_HOME=$(cd "$(dirname ${_me:-$0})/.." >/dev/null 2>&1; echo $PWD)
unset me

