#!/bin/bash

# Adapted from https://github.com/clayboone/scripts/blob/2ce589cd48fb8b8d4869d432d85e46d2cc96778d/auto_lock_screen.sh

# Settings
declare -a LIST_OF_WINDOW_TITLES_THAT_PREVENT_LOCKING=(
    "YouTube"
    "^Meet - "
)

# Dependencies
AWK=/usr/bin/awk
GREP=/usr/bin/grep
XPROP=/usr/bin/xprop

# Find active window id
get_active_id() {
    $XPROP -root -notype 0x '=$0' _NET_ACTIVE_WINDOW | cut -f 2 -d =
}

# Determine a window's title text by it's ID
get_window_title() {
    # For mplayer or vlc, we might need to check WM_CLASS(STRING), idk.
    $XPROP -id $1 -notype 0u '=$0' _NET_WM_NAME | cut -f 2 -d '=' | xargs echo
}

# Determine if a window is fullscreen based on it's ID
is_fullscreen() {
    state=$($XPROP -id $1 -notype _NET_WM_STATE | cut -f 2 -d '=' | tr -d ',')
	for s in ${state}; do
		if [ "$s" = "_NET_WM_STATE_FULLSCREEN" ]; then
			return 0
		fi
	done
	return 0
}

# Determine if the locker command should run based on which windows are
# fullscreened.
should_lock() {
    id=$(get_active_id)
    title=$(get_window_title $id)

    if is_fullscreen $id; then
        for i in "${LIST_OF_WINDOW_TITLES_THAT_PREVENT_LOCKING[@]}"; do
            if echo "${title}" | grep -E "$i" >/dev/null 2>&1; then
                return 1
            fi
        done
    else
        return 0
    fi
}

# main()
if should_lock; then
    sh -c "$1"
fi
