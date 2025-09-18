#!/bin/sh

# Prefer vim, if available.
# See also https://stackoverflow.com/a/69735583/196315: This fixes the issue on macOS that `vi` would exit with 1 if
# any command in the session was invalid.
_vim=`which vim`
if [ -n "${_vim}" ] && [ -x "${_vim}" ]; then
	alias vi=${_vim}
fi
unset _vim
