#!/bin/sh

# Electron 28+: Use wayland if possible
# See https://github.com/electron/electron/blob/main/docs/api/environment-variables.md#electron_ozone_platform_hint-linux
ELECTRON_OZONE_PLATFORM_HINT=auto

# Default browser
# This should be aligned with the xdg settings:
XDG_DEFAULT_BROWSER=$(xdg-settings get default-web-browser 2>/dev/null || echo "")
if [ -n "${XDG_DEFAULT_BROWSER}" ]; then
	BROWSER=${XDG_DEFAULT_BROWSER}
fi
