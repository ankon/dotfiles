#!/bin/sh

# Electron 28+: Use wayland if possible
# See https://github.com/electron/electron/blob/main/docs/api/environment-variables.md#electron_ozone_platform_hint-linux
ELECTRON_OZONE_PLATFORM_HINT=auto
export ELECTRON_OZONE_PLATFORM_HINT

# Firefox: Use wayland when we're in a wayland session
if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    export MOZ_ENABLE_WAYLAND=1
fi

# Default browser
# This should be aligned with the xdg settings:
XDG_DEFAULT_BROWSER=$(xdg-settings get default-web-browser 2>/dev/null || echo "")
if [ -n "${XDG_DEFAULT_BROWSER}" ]; then
	BROWSER=${XDG_DEFAULT_BROWSER}
fi
export XDG_DEFAULT_BROWSER BROWSER
