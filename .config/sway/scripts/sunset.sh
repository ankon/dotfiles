#!/usr/bin/env sh

# Modified from https://github.com/manjaro-sway/desktop-settings/blob/35240596e354c70a05dfb111ee7873ef84540936/community/sway/usr/share/sway/scripts/sunset.sh
# Modified from https://github.com/manjaro-sway/desktop-settings/blob/35240596e354c70a05dfb111ee7873ef84540936/community/sway/usr/bin/waybar-signal

waybar_signal() {
	# Hardcoded in waybar as `signal` for "custom/sunset"
	number=6

	pkill -x -SIGRTMIN+${number} 'waybar'
}

config="$HOME/.config/wlsunset/config"

#Startup function
start() {
    [ -f "$config" ] && . "$config"
    temp_low=${temp_low:-"4000"}
    temp_high=${temp_high:-"6500"}
    duration=${duration:-"900"}
    sunrise=${sunrise:-"07:00"}
    sunset=${sunset:-"19:00"}
    location=${location:-"on"}
    fallback_longitude=${fallback_longitude:-"8.7"}
    fallback_latitude=${fallback_latitude:-"50.1"}

    if [ "${location}" = "on" ]; then
        if [ -z ${longitude+x} ] || [ -z ${latitude+x} ]; then
            GEO_CONTENT=$(curl -sL https://manjaro-sway.download/geoip)
        fi
        longitude=${longitude:-$(echo "$GEO_CONTENT" | jq -r '.longitude // empty')}
        longitude=${longitude:-$fallback_longitude}
        latitude=${latitude:-$(echo "$GEO_CONTENT" | jq -r '.latitude // empty')}
        latitude=${latitude:-$fallback_latitude}

        echo longitude: "$longitude" latitude: "$latitude"

        wlsunset -l "$latitude" -L "$longitude" -t "$temp_low" -T "$temp_high" -d "$duration" &
    else
        wlsunset -t "$temp_low" -T "$temp_high" -d "$duration" -S "$sunrise" -s "$sunset" &
    fi
}

#Accepts managing parameter
case $1'' in
'off')
    pkill -x wlsunset
    waybar_signal sunset
    ;;
'on')
    start
    waybar_signal sunset
    ;;
'toggle')
    if pkill -x -0 wlsunset; then
        pkill -x wlsunset
    else
        start
    fi
    waybar_signal sunset
    ;;
'check')
    command -v wlsunset
    exit $?
    ;;
esac

#Returns a string for Waybar
if pkill -x -0 wlsunset; then
    class="on"
    text="location-based gamma correction"
else
    class="off"
    text="no gamma correction"
fi

printf '{"alt":"%s","tooltip":"%s"}\n' "$class" "$text"