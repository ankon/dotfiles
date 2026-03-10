#!/bin/sh

# See https://github.com/alacritty/alacritty/issues/7360#issuecomment-1807232351
LANG="${LC_ALL:-$LANG}"
if [ -z "${LANG}" ]; then
	LANG=C
fi
export LANG
unset LC_ALL

# Include the user's .bashrc
[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
